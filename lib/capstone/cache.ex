defmodule Capstone.Cache do
  def get(key) do
    GenServer.call(Capstone.CacheServer, {:get, key})
  end

  def set(key, value) do
    GenServer.cast(Capstone.CacheServer, {:set, key, value})
  end
end
