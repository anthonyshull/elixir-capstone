defmodule Capstone.Weather do
  @moduledoc """
  This module is responsible for fetching weather data from the National Weather Service API.
  """

  use Timex

  alias Capstone.Weather.Api

  @doc """
  Gets grid information for a given latitude and longitude.
  """
  @spec get_grid!(float(), float()) :: %{String.t() => any}
  def get_grid!(latitude, longitude) do
    %{"gridId" => grid_id, "gridX" => grid_x, "gridY" => grid_y} =
      Api.get_grid_response!(latitude, longitude)
      |> Map.get("properties")
      |> Map.take(["gridId", "gridX", "gridY"])

    %{"grid_id" => grid_id, "grid_x" => grid_x, "grid_y" => grid_y}
  end

  @doc """
  Gets weather information for a given grid.
  """
  @spec get_weather!(String.t(), integer(), integer()) :: %{String.t() => String.t()}
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
