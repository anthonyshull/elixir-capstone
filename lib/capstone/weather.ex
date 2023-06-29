defmodule Capstone.Weather do
  use Timex

  alias Capstone.Weather.Api

  def get_grid!(latitude, longitude) do
    %{"gridId" => grid_id, "gridX" => grid_x, "gridY" => grid_y} =
      Api.get_grid_response!(latitude, longitude)
        |> Map.get("properties")
        |> Map.take(["gridId", "gridX", "gridY"])

    %{"grid_id" => grid_id, "grid_x" => grid_x, "grid_y" => grid_y}
  end

  def get_weather!(grid_id, grid_x, grid_y) do
    %{"endTime" => end_time, "shortForecast" => weather} =
      Api.get_weather_response!(grid_id, grid_x, grid_y)
        |> Map.fetch!("properties")
        |> Map.fetch!("periods")
        |> Enum.fetch!(0)
        |> Map.take(["endTime", "shortForecast"])

    end_time = end_time |> Timex.parse!("{ISO:Extended}") |> Timezone.convert(Timezone.get("UTC"))

    %{"end_time" => end_time, "weather" => weather}
  end
end
