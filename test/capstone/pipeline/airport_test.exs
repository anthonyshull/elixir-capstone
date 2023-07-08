defmodule Capstone.Pipeline.AirportTest do
  use ExUnit.Case
  use Capstone.Support.DataCase

  import Capstone.Factory.Airport, only: [airport_factory: 0, insert: 1]

  setup do
    %{airport: insert(:airport)}
  end

  test "test message", %{airport: airport} do
    city_state = %{"city" => airport.city, "state" => airport.state} |> Jason.encode!()

    ref = Broadway.test_message(Capstone.Pipeline.Airport, city_state)

    # assert_receive {:ack, ^ref, [%{data: 1}], []}
  end
end
