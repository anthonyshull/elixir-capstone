defmodule Capstone.Pipeline.Weather do
  use Broadway

  require Logger

  alias Capstone.{Cache, NationalWeatherService}

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
    data = message.data |> Jason.decode!()

    %{"grid_id" => grid_id, "grid_x" => grid_x, "grid_y" => grid_y} = data
    key = "#{grid_id},#{grid_x},#{grid_y}"

    weather =
      case Cache.get("#{key},#{next_hour()}") do
        nil ->
          %{"end_time" => end_time, "weather" => weather} = NationalWeatherService.get_weather!(grid_id, grid_x, grid_y)

          Cache.set("#{key},#{end_time}", weather)

          weather
        value ->
          value
      end

    data = Map.merge(data, %{"weather" => weather})
    message = Broadway.Message.put_data(message, data)

    AMQP.Basic.publish(message.metadata.amqp_channel, "", "weather_out", data |> Jason.encode!())

    message
  end

  defp next_hour do
    Timex.now |> end_of_hour()
  end

  defp end_of_hour(date_time) do
    date_time |> Map.replace(:minute, 0) |> Map.replace(:second, 0) |> Timex.shift(hours: 1) |> Map.replace(:microsecond, {0, 0})
  end
end