import Config

config :capstone, Capstone.Repo,
  database: "capstone_test",
  username: "capstone",
  password: "capstone",
  hostname: "localhost",
  log: false,
  pool: Ecto.Adapters.SQL.Sandbox

config :capstone,
  airport_producer_module: Broadway.DummyProducer,
  airport_producer_config: []
