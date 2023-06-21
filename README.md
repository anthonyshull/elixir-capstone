# Capstone

This is a capstone project...

## Usage

```
%> iex -S mix
```

```elixir
iex> GenServer.cast(Capstone.CacheServer, {:set, "foo", "bar"})
iex> GenServer.call(Capstone.CacheServer, {:get, "foo"})
"bar"
```