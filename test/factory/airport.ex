defmodule Capstone.Factory.Airport do
  use ExMachina.Ecto, repo: Capstone.Repo
  alias Capstone.Airport

  def airport_factory() do
    %Airport{
      code: Faker.Airports.iata(),
      name: Faker.Airports.name(),
      type: ["large_airport", "medium_airport", "small_airport"] |> Enum.random(),
      city: Faker.Address.city(),
      state: Faker.Address.state_abbr(),
      country: "US",
      latitude: Faker.Address.latitude(),
      longitude: Faker.Address.longitude(),
      grid_id: Faker.Lorem.word() |> String.slice(0, 3) |> String.upcase(),
      grid_x: Faker.Number.number(2),
      grid_y: Faker.Number.number(2)
    }
  end
end
