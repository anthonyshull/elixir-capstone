# Capstone

At a high level, this project aims to get weather forecasts for airports in the United States.
You can place a message with a `city,state` on [RabbitMQ](https://www.rabbitmq.com).
All airports in that city will be loaded from the database using [Ecto](https://hexdocs.pm/ecto/Ecto.html).
We will check for current weather in our local cache (which uses [dets](https://www.erlang.org/doc/man/dets.html)).
If the cache misses, we'll fetch the latest weather from the [NOAA API](https://www.ncdc.noaa.gov/cdo-web/webservices/v2).
This is all wired together as a data-ingestion pipeline using [Broadway](https://elixir-broadway.org).

There is no real practical use for the project; it is just a capstone to reinforce learning from these books:

- [Concurrent Data Processing in Elixir](https://pragprog.com/titles/sgdpelixir/concurrent-data-processing-in-elixir/)
- [Programming Ecto](https://pragprog.com/titles/wmecto/programming-ecto/)
- [Testing Elixir](https://pragprog.com/titles/lmelixir/testing-elixir/)

## Setup

```
%> docker run --hostname tickets --name rabbitmq -p 5672:5672 -d rabbitmq
%> docker run -e POSTGRES_DB=capstone -e POSTGRES_USER=capstone -e POSTGRES_PASSWORD=capstone \
   --name postgres -p 5432:5432 -d postgres
%> mix ecto.migrate
```

## Usage

```
%> iex -S mix
```

Starting up [iex](https://hexdocs.pm/iex/1.12/IEx.html) will kick off the seeding of airport data.
It will first check for the presence of a CSV file containing airport data.
If the file does not exist, it will download and save the file.
It then loads and parses the file in a [stream](https://hexdocs.pm/elixir/1.12/Stream.html), validates each airport entry against a [schema](https://hexdocs.pm/ecto/Ecto.Schema.html), and inserts the airports in batches of 100.
The process is idempotent--it should take a few seconds to run the first time you load iex.
Thereafter, it will take milliseconds.

```elixir
iex> Capstone.Cache.set("foo", "bar")
iex> Capstone.Cache.get("foo")
"bar"
```