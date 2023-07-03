defmodule Capstone.Time do
  def next_hour(date_time \\ Timex.now()) do
    date_time
    |> Map.replace(:minute, 0)
    |> Map.replace(:second, 0)
    |> Timex.shift(hours: 1)
    |> Map.replace(:microsecond, {0, 0})
  end
end
