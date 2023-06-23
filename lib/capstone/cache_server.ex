defmodule Capstone.CacheServer do
  use GenServer

  @table_name :cache

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    :dets.open_file(@table_name, [{:file, "/tmp/#{@table_name}" |> String.to_charlist()}])

    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case :dets.lookup(@table_name, key) do
      [{^key, value}] -> {:reply, value, state}
      [] -> {:reply, nil, state}
    end
  end

  @impl true
  def handle_cast({:set, key, value}, state) do
    :dets.insert(@table_name, {key, value})

    {:noreply, state}
  end
end