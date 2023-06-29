defmodule Capstone.NationalWeatherService.Api do
  @behaviour Capstone.Weather.Api

  @impl Capstone.Weather.Api
  def get_grid_response!(latitude, longitude) do
    "https://api.weather.gov/points/#{latitude},#{longitude}"
      |> Req.get!(redirect_log_level: false)
      |> (&(&1.body)).()
  end

  @impl Capstone.Weather.Api
  def get_weather_response!(grid_id, grid_x, grid_y) do
    "https://api.weather.gov/gridpoints/#{grid_id}/#{grid_x},#{grid_y}/forecast/hourly"
      |> Req.get!(redirect_log_level: false)
      |> (&(&1.body)).()
  end
end
