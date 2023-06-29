defmodule Capstone.Cache do
  alias Capstone.Cache.Server

  def get(key) do
    GenServer.call(Server, {:get, key})
  end

  def set(key, value) do
    GenServer.cast(Server, {:set, key, value})
  end
end
