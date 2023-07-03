defmodule Capstone.Pipeline.Airport do
  use Broadway

  require Logger

  alias Capstone.Airport

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "airport_pipeline"
  ]

  def start_link(_args) do
    options = [
      name: Capstone.Pipeline.Airport,
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    Enum.map(message.data, fn airport ->
      channel = message.metadata.amqp_channel
      payload = airport |> Jason.encode!()
      routing_key = if airport.grid_id == nil, do: "grid_pipeline", else: "weather_pipeline"

      AMQP.Basic.publish(channel, "", routing_key, payload)
    end)

    message
  end

  def prepare_messages(messages, _context) do
    grouped_messages = group_messages(messages)
    airports = Airport.in_cities_states(grouped_messages |> Map.keys())

    put_airports_in_messages(grouped_messages, airports)
  end

  defp group_messages(messages) do
    Enum.group_by(messages, fn message ->
      message.data
      |> Jason.decode!()
      |> Map.take(["city", "state"])
      |> Map.values()
      |> List.to_tuple()
    end)
  end

  defp put_airports_in_messages(grouped_messages, airports) do
    Enum.map(grouped_messages, fn {city_state, messages} ->
      airports = Map.get(airports, city_state, [])

      [head | tail] = messages

      Enum.map(tail, fn message -> Broadway.Message.put_data(message, []) end)
      |> List.insert_at(0, Broadway.Message.put_data(head, airports))
    end)
    |> List.flatten()
  end
end
