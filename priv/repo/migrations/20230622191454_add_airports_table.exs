defmodule Capstone.Repo.Migrations.AddAirportsTable do
  use Ecto.Migration

  def change do
    create table("airports", primary_key: false) do
      add :code, :string, null: false, primary_key: true
      add :name, :string, null: false
      add :city, :string, null: false
      add :state, :string, null: false
    end

    create index("airports", [:city, :state])
  end
end
