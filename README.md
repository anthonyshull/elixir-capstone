# Capstone

This data pipeline uses [Broadway](https://elixir-broadway.org), [dets](https://www.erlang.org/doc/man/dets.html), [Ecto](https://hexdocs.pm/ecto/Ecto.html), and [kafka](https://kafka.apache.org).

This is a capstone project to reinforce learnings from three books:

- [Concurrent Data Processing in Elixir](https://pragprog.com/titles/sgdpelixir/concurrent-data-processing-in-elixir/)
- [Programming Ecto](https://pragprog.com/titles/wmecto/programming-ecto/)
- [Testing Elixir](https://pragprog.com/titles/lmelixir/testing-elixir/)

## Setup
```
%> docker run -e POSTGRES_DB=capstone -e POSTGRES_USER=capstone -e POSTGRES_PASSWORD=capstone \
   --name capstone -p 5432:5432 -d postgres
%> mix ecto.migrate
%> mix run priv/repo/seed.exs
```

Running the seed file will first check for the presence of a CSV file containing airport data.
If the file does not exist, it will download and save the file.
It then loads the file, validates each entry against an [Ecto.Schema](https://hexdocs.pm/ecto/Ecto.Schema.html), and inserts the airports in chunks of 100.

## Usage

```
%> iex -S mix
```

```elixir
iex> Capstone.Cache.set("foo", "bar")
iex> Capstone.Cache.get("foo")
"bar"
```