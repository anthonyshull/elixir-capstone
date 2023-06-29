defmodule Capstone.Cache do
  alias Capstone.CacheServer

  def get(key) do
    GenServer.call(CacheServer, {:get, key})
  end

  def set(key, value) do
    GenServer.cast(CacheServer, {:set, key, value})
  end
end
