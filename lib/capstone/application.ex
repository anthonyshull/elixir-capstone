defmodule Capstone.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Capstone.Cache.Server,
      Capstone.Repo,
      Capstone.Pipeline.Airport,
      Capstone.Pipeline.Grid,
      Capstone.Pipeline.Weather
    ]

    opts = [strategy: :one_for_one, name: Capstone.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
