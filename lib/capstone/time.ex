defmodule Capstone.Time do
  def next_hour do
    Timex.now |> end_of_hour()
  end

  defp end_of_hour(date_time) do
    date_time
    |> Map.replace(:minute, 0)
    |> Map.replace(:second, 0)
    |> Timex.shift(hours: 1)
    |> Map.replace(:microsecond, {0, 0})
  end
end
