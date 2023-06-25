lookup = fn(city, state) ->
  {:ok, connection} = AMQP.Connection.open()
  {:ok, channel} = AMQP.Channel.open(connection)

  AMQP.Queue.declare(channel, "weather_pipeline")

  AMQP.Queue.subscribe(channel, "weather_pipeline", fn payload, _meta ->
    payload |> Jason.decode!() |> IO.inspect()
  end)

  AMQP.Basic.publish(channel, "", "airport_pipeline", %{"city" => city, "state" => state} |> Jason.encode!())

  channel
end
