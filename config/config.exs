import Config

config :capstone, Capstone.Repo,
  database: "capstone",
  username: "capstone",
  password: "capstone",
  hostname: "localhost"

config :capstone, :ecto_repos, [Capstone.Repo]
