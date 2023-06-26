defmodule Capstone.GridPipeline do
  use Broadway

  require Logger

  alias Capstone.{Airport, Repo}

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "grid_pipeline"
  ]

  def start_link(_args) do
    options = [
      name: GridPipeline,
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    channel = message.metadata.amqp_channel

    airport = Repo.get(Airport, Map.get(message.data, "code"))
    airport = Airport.changeset(airport, Map.drop(message.data, ["code"]))
    airport = Repo.update!(airport)

    Logger.debug("Publishing to weather pipeline: #{airport.name}")
    AMQP.Basic.publish(channel, "", "weather_pipeline", airport |> Jason.encode!())

    message
  end

  def prepare_messages(messages, _context) do
    Enum.map(messages, &prepare_message/1)
  end

  defp api_url(latitude, longitude) do
    "https://api.weather.gov/points/#{latitude},#{longitude}"
  end

  defp prepare_message(message) do
    map = message.data |> Jason.decode!()

    data =
      api_url(Map.get(map, "latitude"), Map.get(map, "longitude"))
      |> Req.get!(redirect_log_level: false)
      |> (fn request -> request.body end).()
      |> Map.get("properties")
      |> Map.take(["gridId", "gridX", "gridY"])

    grid = %{"grid_id" => data["gridId"], "grid_x" => data["gridX"], "grid_y" => data["gridY"]}

    Broadway.Message.put_data(message, Map.merge(map, grid))
  end
end
