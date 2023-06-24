defmodule Capstone.Repo.Migrations.AddAirportsTable do
  use Ecto.Migration

  def change do
    create table("airports", primary_key: false) do
      add :code, :string, null: false, primary_key: true

      add :name, :string, null: false
      add :type, :string, null: false

      add :city, :string, null: false
      add :state, :string, null: false
      add :country, :string, null: false

      add :latitude, :float, null: false
      add :longitude, :float, null: false

      add :grid_id, :string
      add :grid_x, :integer
      add :grid_y, :integer
    end

    create index("airports", [:city, :state])
  end
end
