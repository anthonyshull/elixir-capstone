defmodule Capstone.Pipeline.Weather do
  use Broadway
  use Timex

  require Logger

  alias Capstone.Cache

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "weather_pipeline"
  ]

  def start_link(_args) do
    options = [
      name: Capstone.Pipeline.Weather,
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    Logger.debug("Publishing to weather out: #{message.data["name"]}")
    AMQP.Basic.publish(message.metadata.amqp_channel, "", "weather_out", message.data |> Jason.encode!())

    message
  end

  def prepare_messages(messages, _context) do
    Enum.map(messages, &prepare_message/1)
  end

  defp api_url(grid_id, grid_x, grid_y) do
    "https://api.weather.gov/gridpoints/#{grid_id}/#{grid_x},#{grid_y}/forecast/hourly"
  end

  defp prepare_message(message) do
    map = message.data |> Jason.decode!()
    %{"grid_id" => grid_id, "grid_x" => grid_x, "grid_y" => grid_y} = map
    key = "#{grid_id},#{grid_x},#{grid_y}"

    forecast =
      case Cache.get("#{key},#{next_hour()}") do
        nil ->
          data =
            api_url(grid_id, grid_x, grid_y)
            |> Req.get!(redirect_log_level: false)
            |> (&(&1.body)).()
            |> Map.fetch!("properties")
            |> Map.fetch!("periods")
            |> Enum.fetch!(0)
            |> Map.take(["endTime", "shortForecast"])

          end_time = data["endTime"] |> Timex.parse!("{ISO:Extended}") |> Timezone.convert(Timezone.get("UTC"))
          Cache.set("#{key},#{end_time}", data["shortForecast"])

          Logger.debug("Cache miss for #{key} : #{end_time} : #{next_hour()}")

          data["shortForecast"]
        value ->
          Logger.debug("Cache hit for #{key}")

          value
      end

    weather = %{"weather" => forecast}

    Broadway.Message.put_data(message, Map.merge(map, weather))
  end

  defp next_hour do
    Timex.now |> end_of_hour()
  end

  defp end_of_hour(date_time) do
    date_time |> Map.replace(:minute, 0) |> Map.replace(:second, 0) |> Timex.shift(hours: 1) |> Map.replace(:microsecond, {0, 0})
  end
end
