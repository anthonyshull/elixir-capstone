defmodule Capstone.Repo.Migrations.AddAirportsTable do
  use Ecto.Migration

  def change do
    create table("airports", primary_key: false) do
      add :code, :string, null: false, primary_key: true

      add :city, :string, null: false
      add :country, :string, null: false
      add :name, :string, null: false
      add :state, :string, null: false
      add :type, :string
    end

    create index("airports", [:city, :state])
  end
end
