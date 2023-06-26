require Logger

lookup = fn(city, state) ->
  {:ok, connection} = AMQP.Connection.open()
  {:ok, channel} = AMQP.Channel.open(connection)

  AMQP.Queue.declare(channel, "weather_out")

  AMQP.Queue.subscribe(channel, "weather_out", fn payload, _meta ->
    payload |> Jason.decode!() |> Map.take(["name", "weather"]) |> Jason.encode!() |> Logger.info
  end)

  AMQP.Basic.publish(channel, "", "airport_pipeline", %{"city" => city, "state" => state} |> Jason.encode!())

  channel
end
