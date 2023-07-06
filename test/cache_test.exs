defmodule Capstone.CacheTest do
  use ExUnit.Case, async: true

  alias Capstone.Cache

  test "get/2 sets the cache with a function when no value is present" do
    key = Faker.Lorem.word()
    value = Faker.Lorem.word()

    Cache.get(key, fn -> value end)

    assert Cache.get(key) != nil
  end

  test "set/2 work with a busted cache" do
    key = Faker.Lorem.word()
    value = Faker.Lorem.word()

    [interval: interval] = :sys.replace_state(Cache, fn _ -> [interval: 1] end)

    Cache.set(key, value)

    assert Cache.get(key) == value

    Process.sleep(interval + 100)

    assert Cache.get(key) == nil
  end
end
