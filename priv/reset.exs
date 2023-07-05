require Logger

Code.require_file("priv/repo/seed.ex")

case File.rm(Capstone.Cache.save_path()) do
  :ok -> Logger.info("Cache file cleared")
  _ -> :ok
end

case File.rm(Seed.save_path()) do
  :ok -> Logger.info("Airport data file cleared")
  _ -> :ok
end

Logger.info("Seeding airport data")

Seed.seed()
