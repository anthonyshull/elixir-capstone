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

      if airport.grid_id == nil do
        AMQP.Basic.publish(channel, "", "grid_pipeline", payload)
      else
        AMQP.Basic.publish(channel, "", "weather_pipeline", payload)
      end
    end)

    message
  end

  def prepare_messages(messages, _context) do
    messages_by_city_state = Enum.group_by(messages, fn message ->
      message.data |> Jason.decode!() |> Map.take(["city", "state"]) |> Map.values() |> List.to_tuple()
    end)

    airports = Airport.in_cities_states(messages_by_city_state |> Map.keys())

    Enum.map(messages_by_city_state, fn {city_state, messages} ->
      airports = Map.get(airports, city_state, [])

      [head | tail] = messages

      Enum.map(tail, fn message -> Broadway.Message.put_data(message, inspect(city_state)) end)
      |> List.insert_at(0, Broadway.Message.put_data(head, airports))
    end) |> List.flatten()
  end
end
