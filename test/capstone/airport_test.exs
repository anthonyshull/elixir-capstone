defmodule Capstone.AirportTest do
  use ExUnit.Case, async: true
  use Capstone.Support.DataCase

  import Ecto.Query, only: [first: 1, from: 2, last: 1]
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
    test "the correct number of airports get returned" do
      Enum.map(0..3, fn _ -> insert(:airport) end)

      one = Airport |> first() |> Repo.one()
      two = Airport |> last() |> Repo.one()

      keys = [one, two] |> Enum.map(&{&1.city, &1.state})

      two |> Ecto.Changeset.change(city: one.city, state: one.state) |> Repo.update!()
      airports = Airport.in_cities_states(keys)

      query = fn {city, state} ->
        from(a in Airport, where: a.city == ^city and a.state == ^state)
      end

      assert Map.get(airports, List.first(keys)) |> Enum.count() ==
               query.(List.first(keys)) |> Repo.all() |> Enum.count()

      assert Map.get(airports, List.last(keys)) == nil
    end

    test "an empty map gets returned when no values are found" do
      Repo.delete_all(Airport)

      assert Airport.in_cities_states([{Faker.Address.city(), Faker.Address.state_abbr()}]) == %{}
    end
  end
end
