defmodule Capstone.WeatherTest do
  use ExUnit.Case, async: true

  import Mox

  setup_all do
    %{
      end_time: Faker.DateTime.forward(4),
      grid_id: Faker.Code.issn(),
      grid_x: Enum.random(0..99),
      grid_y: Enum.random(0..99)
    }
  end

  setup :verify_on_exit!

  test "get_grid!/2 returns a map with grid_id, grid_x, and grid_y", %{
    grid_id: grid_id,
    grid_x: grid_x,
    grid_y: grid_y
  } do
    response = %{"properties" => %{"gridId" => grid_id, "gridX" => grid_x, "gridY" => grid_y}}
    expected = %{"grid_id" => grid_id, "grid_x" => grid_x, "grid_y" => grid_y}

    Capstone.MockWeather.Api
    |> expect(:get_grid_response!, fn _latitude, _longitude -> response end)

    assert Capstone.Weather.get_grid!(Faker.Address.latitude(), Faker.Address.longitude()) ==
             expected
  end

  test "get_weather!/3 returns a map with end_time and weather", context do
    response = %{
      "properties" => %{
        "periods" => [
          %{
            "endTime" => context.end_time |> DateTime.to_iso8601(),
            "shortForecast" => "Sunny"
          }
        ]
      }
    }

    expected = %{"end_time" => context.end_time, "weather" => "Sunny"}

    Capstone.MockWeather.Api
    |> expect(:get_weather_response!, fn _grid_id, _grid_x, _grid_y -> response end)

    assert Capstone.Weather.get_weather!(context.grid_id, context.grid_x, context.grid_y) ==
             expected
  end
end
