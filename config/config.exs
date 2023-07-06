import Config

config :capstone, :ecto_repos, [Capstone.Repo]

config :exvcr,
  vcr_cassette_library_dir: "tmp/fixtures"

import_config "#{config_env()}.exs"
