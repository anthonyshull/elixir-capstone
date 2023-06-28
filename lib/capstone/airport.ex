defmodule Capstone.Airport do
  use Ecto.Schema

  alias Capstone.Repo

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:code, :name, :type, :city, :state, :country, :latitude, :longitude, :grid_id, :grid_x, :grid_y]}
  @primary_key {:code, :string, autogenerate: false}

  schema "airports" do
    field :name, :string
    field :type, :string

    field :city, :string
    field :state, :string
    field :country, :string

    field :latitude, :float
    field :longitude, :float

    field :grid_id, :string
    field :grid_x, :integer
    field :grid_y, :integer
  end

  @doc false
  def changeset(airport, attrs) do
    airport
    |> cast(attrs, [:name, :type, :city, :state, :country, :latitude, :longitude, :grid_id, :grid_x, :grid_y])
    |> validate_required([:name, :type, :city, :state, :country, :latitude, :longitude])
    |> validate_inclusion(:type, ["large_airport", "medium_airport", "small_airport"])
    |> validate_inclusion(:country, ["US"])
  end

  def in_cities_states(cities_states) do
    cities_states = Enum.map(cities_states, fn {city, state} ->  "('#{city}','#{state}')" end) |> Enum.join(",")

    {:ok, result} = Repo.query("SELECT * FROM airports WHERE (city, state) IN (#{cities_states})")

    Enum.map(result.rows, &Repo.load(__MODULE__, {result.columns, &1})) |> Enum.group_by(&(&1.city <> &1.state))
  end
end
