defmodule Capstone.Cache do
  use GenServer

  @table_name :cache
  @save_path "/tmp/#{@table_name}"

  def save_path, do: @save_path

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def set(key, value) do
    GenServer.cast(__MODULE__, {:set, key, value})
  end

  @impl true
  def init(args) do
    :dets.open_file(@table_name, [{:file, @save_path |> String.to_charlist()}])

    {:ok, args}
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
    interval = Keyword.fetch!(state, :interval)

    :dets.insert(@table_name, {key, value})

    Process.send_after(__MODULE__, {:bust, key}, interval)

    {:noreply, state}
  end

  @impl true
  def handle_info({:bust, key}, state) do
    :dets.delete(@table_name, key)

    {:noreply, state}
  end
end
