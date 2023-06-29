defmodule Capstone.Weather.Api do
  @callback get_grid_response!(latitude :: float, longitude :: float) :: map
  @callback get_weather_response!(grid_id :: String.t, grid_x :: integer, grid_y :: integer) :: map

  def get_grid_response!(latitude, longitude), do: impl().get_grid_response!(latitude, longitude)
  def get_weather_response!(grid_id, grid_x, grid_y), do: impl().get_weather_response!(grid_id, grid_x, grid_y)

  defp impl, do: Application.get_env(:capstone, :weather_api, Capstone.NationalWeatherService.Api)
end
