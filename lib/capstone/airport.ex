defmodule Capstone.Airport do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:code, :string, autogenerate: false}

  schema "airports" do
    field :city, :string
    field :country, :string
    field :name, :string
    field :state, :string
    field :type, :string
  end

  @doc false
  def changeset(airport, attrs) do
    airport
    |> cast(attrs, [:city, :code, :country, :name, :state, :type])
    |> validate_required([:city, :code, :name, :state])
    |> validate_inclusion(:type, ["large_airport", "medium_airport", "small_airport"])
    |> validate_inclusion(:country, ["US"])
  end
end
