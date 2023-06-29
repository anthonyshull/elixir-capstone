Mox.defmock(Capstone.MockWeather.Api, for: Capstone.Weather.Api)
Application.put_env(:capstone, :weather_api, Capstone.MockWeather.Api)

ExUnit.start()
