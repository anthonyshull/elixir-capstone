defmodule Capstone.AirportTest do
  use ExUnit.Case, async: true
  use Capstone.Support.DataCase

  import Ecto.Query
  import Capstone.Factory.Airport, only: [airport_factory: 0, insert: 1]

  alias Capstone.Airport

  describe "changeset/2" do
    setup do
      %{airport: airport_factory()}
    end

    test "returns a valid changeset", context do
      name = Faker.Airports.name()
      changeset = Airport.changeset(context.airport, %{name: name})

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.name == name
    end

    test "invalid type", context do
      changeset = Airport.changeset(context.airport, %{type: Faker.Lorem.word()})

      assert %Changeset{valid?: false, errors: errors} = changeset
      assert {"is invalid", _} = errors[:type]
    end

    test "invalid country", context do
      changeset = Airport.changeset(context.airport, %{country: Faker.Address.country_code()})

      assert %Changeset{valid?: false, errors: errors} = changeset
      assert {"is invalid", _} = errors[:country]
    end
  end

  describe "in_cities_states/1" do
    setup do
      %{airports: Enum.map(0..9, fn _ -> insert(:airport) end)}
    end

    test "the correct number of airports get returned", context do
      keys = context.airports |> Enum.map(&{&1.city, &1.state})
      airports = Airport.in_cities_states(keys)

      query = fn {city, state} ->
        from(a in Airport, where: a.city == ^city and a.state == ^state)
      end

      Enum.each(keys, fn key ->
        assert length(airports[key]) == Repo.all(query.(key)) |> length()
      end)
    end

    test "an empty map gets returned when no values are found" do
      Repo.delete_all(Airport)

      assert Airport.in_cities_states([{Faker.Address.city(), Faker.Address.state_abbr()}]) == %{}
    end
  end
end
