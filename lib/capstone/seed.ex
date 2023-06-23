defmodule Capstone.Seed do
  alias NimbleCSV.RFC4180, as: CSV
  alias Capstone.{Airport, Repo}

  @download_url "https://davidmegginson.github.io/ourairports-data/airports.csv"
  @save_path "/tmp/airports.csv"

  def seed() do
    airports_csv()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&row_to_map/1)
    |> Stream.filter(fn map ->
      Airport.changeset(%Airport{}, map).valid?
    end)
    |> Stream.chunk_every(100)
    |> Task.async_stream(&insert_batch/1, max_concurrency: 10, ordered: false)
    |> Stream.run()
  end

  defp airports_csv() do
    unless File.exists?(@save_path) do
      @download_url
      |> Req.get!()
      |> (fn request -> request.body end).()
      |> CSV.dump_to_iodata()
      |> IO.iodata_to_binary()
      |> (fn data -> File.write!(@save_path, data) end).()
    end

    @save_path
  end

  defp insert_batch(data) do
    Repo.insert_all(Airport, data, on_conflict: :nothing, returning: [:code])
  end

  defp row_to_map(row) do
    %{
      code: :binary.copy(Enum.at(row, 0)),
      city: :binary.copy(Enum.at(row, 10)),
      country: :binary.copy(Enum.at(row, 8)),
      name: :binary.copy(Enum.at(row, 3)),
      state: :binary.copy(Enum.at(row, 9)) |> String.slice(3, 2),
      type: :binary.copy(Enum.at(row, 2))
    }
  end
end
