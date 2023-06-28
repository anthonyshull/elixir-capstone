defmodule Capstone.Pipeline.Airport do
  use Broadway

  require Logger

  alias Capstone.{Airport, Repo}

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "airport_pipeline"
  ]

  def start_link(_args) do
    options = [
      name: Capstone.Pipeline.Airport,
      producer: [module: {@producer, @producer_config}],
      processors: [default: []]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    channel = message.metadata.amqp_channel

    Enum.map(message.data, fn airport ->
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
    city_states = Enum.map(messages, fn message ->
      %{"city" => city, "state" => state} = message.data |> Jason.decode!()

      "('#{city}','#{state}')"
    end) |> Enum.join(",")

    {:ok, result} = Repo.query("SELECT * FROM airports WHERE (city, state) IN (#{city_states})")

    airports = Enum.map(result.rows, &Repo.load(Airport, {result.columns, &1})) |> Enum.group_by(&(&1.city <> &1.state)) |> Map.values()

    Enum.zip_with(messages, airports, fn message, airports ->
      Broadway.Message.put_data(message, airports)
    end)
  end
end
