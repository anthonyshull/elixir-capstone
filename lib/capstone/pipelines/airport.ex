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
    channel = message.metadata.amqp_channel

    Enum.map(message.data, fn airport ->
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
    cities_states = Enum.map(messages, fn message ->
      message.data |> Jason.decode!() |> Map.take(["city", "state"]) |> Map.values() |> List.to_tuple()
    end)

    airports = Airport.in_cities_states(cities_states) |> Map.values()

    Enum.zip_with(messages, airports, fn message, airports ->
      Broadway.Message.put_data(message, airports)
    end)
  end
end
