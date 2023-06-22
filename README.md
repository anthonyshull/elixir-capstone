# Capstone

This data pipeline uses [Broadway](https://elixir-broadway.org), [dets](https://www.erlang.org/doc/man/dets.html), [Ecto](https://hexdocs.pm/ecto/Ecto.html), [Flow](https://hexdocs.pm/flow/Flow.html), and [kafka](https://kafka.apache.org).

This is a capstone project to reinforce learnings from three books:

- [Concurrent Data Processing in Elixir](https://pragprog.com/titles/sgdpelixir/concurrent-data-processing-in-elixir/)
- [Programming Ecto](https://pragprog.com/titles/wmecto/programming-ecto/)
- [Testing Elixir](https://pragprog.com/titles/lmelixir/testing-elixir/)

## Setup
```
%> docker run --name postgres -p 5432:5432 -e POSTGRES_DB=capstone \
   -e POSTGRES_USER=capstone -e POSTGRES_PASSWORD=capstone -d postgres
%> mix ecto.migrate
```

## Usage

```
%> iex -S mix
```

```elixir
iex> GenServer.cast(Capstone.CacheServer, {:set, "foo", "bar"})
iex> GenServer.call(Capstone.CacheServer, {:get, "foo"})
"bar"
```