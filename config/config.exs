import Config

config :capstone, Capstone.Repo,
  database: "capstone",
  username: "capstone",
  password: "capstone",
  hostname: "localhost",
  log: false

config :capstone, :ecto_repos, [Capstone.Repo]
