Mox.defmock(Capstone.MockWeather.Api, for: Capstone.Weather.Api)
Application.put_env(:capstone, :weather_api, Capstone.MockWeather.Api)

ExUnit.start()
Faker.start()

{:ok, _} = Application.ensure_all_started(:ex_machina)
