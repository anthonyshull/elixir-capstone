defmodule Capstone.CacheTest do
  use ExUnit.Case, async: true

  alias Capstone.Cache

  test "set/2 and get/1 work with a busted cache" do
    key = Faker.Lorem.word()
    value = Faker.Lorem.word()

    [interval: interval] = :sys.replace_state(Cache, fn _ -> [interval: 100] end)

    Cache.set(key, value)

    assert Cache.get(key) == value

    Process.sleep(interval + 100)

    assert Cache.get(key) == nil
  end
end
