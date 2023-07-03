defmodule Capstone.TimeTest do
  use ExUnit.Case, async: true

  test "next_hour/1 returns the next hour" do
    now = ~U[2000-01-01 23:59:00Z]
    next_hour = ~U[2000-01-02 00:00:00Z]

    assert Capstone.Time.next_hour(now) == next_hour
  end
end
