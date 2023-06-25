lookup = fn (city, state) ->
  {:ok, connection} = AMQP.Connection.open()
  {:ok, channel} = AMQP.Channel.open(connection)

  AMQP.Basic.publish(channel, "", "cities", "#{city},#{state}")

  AMQP.Connection.close(connection)
end

# lookup and wait for the results
lookup_and_wait = fn(city, state) ->
  lookup.(city, state)
end

Capstone.Seed.seed()
