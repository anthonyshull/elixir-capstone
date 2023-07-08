defmodule Capstone.NationalWeatherService.ApiTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  alias Capstone.NationalWeatherService.Api

  @tag :vcr
  test "get_grid_response!/2" do
    use_cassette "get_grid_response" do
      assert response = Api.get_grid_response!(30.197535, -97.662015)

      assert %{"gridId" => "EWX", "gridX" => 159, "gridY" => 88} = Map.get(response, "properties")
    end
  end

  @tag :vcr
  test "get_weather_response!/3" do
    use_cassette "get_weather_response" do
      assert response = Api.get_weather_response!("EWX", 159, 88)

      assert %{"endTime" => _, "shortForecast" => _} =
               get_in(response, ["properties", "periods"]) |> List.first()
    end
  end
end
