defmodule Capstone.AirportPipeline do
  use Broadway

  require Logger

  import Ecto.Query

  alias Capstone.{Airport, Repo}

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "airport_pipeline"
  ]

  def start_link(_args) do
    options = [
      name: AirportPipeline,
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    channel = message.metadata.amqp_channel

    Enum.each(message.data, fn airport ->
      payload = airport |> Jason.encode!()

      if airport.grid_id == nil do
        Logger.debug("Publishing to grid pipeline: #{airport.name}")
        AMQP.Basic.publish(channel, "", "grid_pipeline", payload)
      else
        Logger.debug("Publishing to weather pipeline: #{airport.name}")
        AMQP.Basic.publish(channel, "", "weather_pipeline", payload)
      end
    end)

    message
  end

  def prepare_messages(messages, _context) do
    Enum.map(messages, &prepare_message/1)
  end

  defp prepare_message(message) do
    %{"city" => city, "state" => state} = message.data |> Jason.decode!()

    airports = Repo.all(from a in Airport, where: a.city == ^city and a.state == ^state)

    Broadway.Message.put_data(message, airports)
  end
end
