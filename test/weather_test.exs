defmodule Capstone.WeatherTest do
  use ExUnit.Case, async: true

  import Mox

  setup_all do
    %{
      end_time: Faker.DateTime.forward(1),
      grid_id: Faker.Code.issn(),
      grid_x: Enum.random(0..99),
      grid_y: Enum.random(0..99)
    }
  end

  setup :verify_on_exit!

  test "get_grid!/2", context do
    expect(Capstone.MockWeather.Api, :get_grid_response!, fn _latitude, _longitude ->
      %{
        "properties" => %{
          "gridId" => context.grid_id,
          "gridX" => context.grid_x,
          "gridY" => context.grid_y
        }
      }
    end)

    expected = %{
      "grid_id" => context.grid_id,
      "grid_x" => context.grid_x,
      "grid_y" => context.grid_y
    }

    actual = Capstone.Weather.get_grid!(Faker.Address.latitude(), Faker.Address.longitude())

    assert actual == expected
  end

  test "get_weather!/3", context do
    expect(Capstone.MockWeather.Api, :get_weather_response!, fn _grid_id, _grid_x, _grid_y ->
      %{
        "properties" => %{
          "periods" => [
            %{
              "endTime" => context.end_time |> DateTime.to_iso8601(),
              "shortForecast" => "Sunny"
            }
          ]
        }
      }
    end)

    expected = %{"end_time" => context.end_time, "weather" => "Sunny"}

    actual = Capstone.Weather.get_weather!(context.grid_id, context.grid_x, context.grid_y)

    assert actual == expected
  end
end
