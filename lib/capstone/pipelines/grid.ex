defmodule Capstone.Pipeline.Grid do
  use Broadway

  require Logger

  alias Capstone.{Airport, Repo, Weather}

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "grid_pipeline"
  ]

  def start_link(_args) do
    options = [
      name: Capstone.Pipeline.Grid,
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    channel = message.metadata.amqp_channel

    airport =
      Repo.get(Airport, Map.get(message.data, "code"))
      |> Airport.changeset(Map.drop(message.data, ["code"]))
      |> Repo.update!()

    AMQP.Basic.publish(channel, "", "weather_pipeline", airport |> Jason.encode!())

    message
  end

  def prepare_messages(messages, _context) do
    Enum.map(messages, &prepare_message/1)
  end

  defp prepare_message(message) do
    map = message.data |> Jason.decode!()

    %{"latitude" => latitude, "longitude" => longitude} = map

    grid = Weather.get_grid!(latitude, longitude)

    Broadway.Message.put_data(message, Map.merge(map, grid))
  end
end
