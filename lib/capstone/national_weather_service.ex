defmodule Capstone.NationalWeatherService do
  use Timex

  defp grid_url(latitude, longitude) do
    "https://api.weather.gov/points/#{latitude},#{longitude}"
  end

  defp weather_url(grid_id, grid_x, grid_y) do
    "https://api.weather.gov/gridpoints/#{grid_id}/#{grid_x},#{grid_y}/forecast/hourly"
  end

  def get_grid!(latitude, longitude) do
    %{"gridId" => grid_id, "gridX" => grid_x, "gridY" => grid_y} =
      grid_url(latitude, longitude)
      |> Req.get!(redirect_log_level: false)
      |> (fn request -> request.body end).()
      |> Map.get("properties")
      |> Map.take(["gridId", "gridX", "gridY"])

    %{"grid_id" => grid_id, "grid_x" => grid_x, "grid_y" => grid_y}
  end

  def get_weather!(grid_id, grid_x, grid_y) do
    %{"endTime" => end_time, "shortForecast" => weather} =
      weather_url(grid_id, grid_x, grid_y)
        |> Req.get!(redirect_log_level: false)
        |> (&(&1.body)).()
        |> Map.fetch!("properties")
        |> Map.fetch!("periods")
        |> Enum.fetch!(0)
        |> Map.take(["endTime", "shortForecast"])

    end_time = end_time |> Timex.parse!("{ISO:Extended}") |> Timezone.convert(Timezone.get("UTC"))

    %{"end_time" => end_time, "weather" => weather}
  end
end
