defmodule Capstone.Airport do
  use Ecto.Schema

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
end
