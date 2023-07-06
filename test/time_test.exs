defmodule Capstone.TimeTest do
  use ExUnit.Case, async: true

  import Capstone.Time

  test "next_hour/1 returns the next hour" do
    now = ~U[2000-01-01 23:59:00Z]
    next_hour = ~U[2000-01-02 00:00:00Z]

    assert next_hour(now) == next_hour
  end

  test "next_hour/1 returns a default time" do
    assert %DateTime{} = next_hour()
  end
end
