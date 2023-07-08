defmodule Capstone.Support.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Query

      import Capstone.Support.DataCase

      alias Ecto.Changeset

      alias Capstone.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Capstone.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Capstone.Repo, {:shared, self()})
    end

    :ok
  end
end
