require Logger

case File.rm(Capstone.CacheServer.save_path()) do
  :ok -> Logger.info("Cache file cleared")
  _ -> :ok
end

case File.rm(Capstone.Seed.save_path()) do
  :ok -> Logger.info("Airport data file cleared")
  _ -> :ok
end
