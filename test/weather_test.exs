defmodule Capstone.WeatherTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  test "get_grid!/2 returns a map with grid_id, grid_x, and grid_y" do
    response = %{ "properties" => %{ "gridId" => "FOO", "gridX" => 0, "gridY" => 99 } }
    expected = %{ "grid_id" => "FOO", "grid_x" => 0, "grid_y" => 99 }

    Capstone.MockWeather.Api
    |> expect(:get_grid_response!, fn _latitude, _longitude -> response end)

    assert Capstone.Weather.get_grid!(0, 0) == expected
  end

  test "get_weather!/3 returns a map with end_time and weather" do
    response = %{
      "properties" => %{
        "periods" => [
          %{
            "endTime" => "2020-01-01T00:00:00-05:00",
            "shortForecast" => "Sunny"
          }
        ]
      }
    }
    expected = %{ "end_time" => ~U[2020-01-01 05:00:00Z], "weather" => "Sunny" }

    Capstone.MockWeather.Api
    |> expect(:get_weather_response!, fn _grid_id, _grid_x, _grid_y -> response end)

    assert Capstone.Weather.get_weather!("FOO", 0, 99) == expected
  end
end
