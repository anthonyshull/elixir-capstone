defmodule Capstone.Weather do
  @moduledoc """
  Fetches grid information and weather information from the [National Weather Service](https://weather-gov.github.io/api/general-faqs).
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
  @spec get_weather!(String.t(), integer(), integer()) :: String.t()
  def get_weather!(grid_id, grid_x, grid_y) do
    Api.get_weather_response!(grid_id, grid_x, grid_y)
    |> get_in(["properties", "periods"])
    |> List.first()
    |> Map.get("shortForecast")
  end
end
