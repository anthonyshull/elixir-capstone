import Config

config :capstone, Capstone.Repo,
  database: "capstone",
  username: "capstone",
  password: "capstone",
  hostname: "localhost",
  log: false

config :capstone,
  airport_producer_module: BroadwayRabbitMQ.Producer,
  airport_producer_config: [
    declare: [durable: true],
    on_failure: :reject,
    queue: "airport_pipeline"
  ]
