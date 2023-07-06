defmodule Capstone.AirportTest do
  use ExUnit.Case, async: true

  import Ecto.Query, only: [first: 1]

  alias Ecto.Changeset
  alias Capstone.{Airport, Repo}

  describe "changeset/2" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    setup do
      %{airport: Airport |> first |> Repo.one()}
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
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    test "there are no airports" do
      assert %{} = Airport.in_cities_states([{"Chicago", "IL"}])
    end
  end
end
