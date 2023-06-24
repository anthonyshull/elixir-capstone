lookup = fn (city, state) ->
  {:ok, connection} = AMQP.Connection.open()
  {:ok, channel} = AMQP.Channel.open(connection)

  AMQP.Basic.publish(channel, "", "cities", "#{city},#{state}")

  AMQP.Connection.close(connection)
end

Capstone.Seed.seed()
