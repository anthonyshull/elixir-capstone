defmodule Capstone.AirportPipeline do
  use Broadway

  import Ecto.Query

  alias Capstone.{Airport, Repo}

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    declare: [durable: true],
    on_failure: :reject,
    queue: "cities"
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
    Enum.each(message.data, fn airport ->
      if airport.grid_id == nil do
        # If the Airport has grid information send it do the weather pipeline
        IO.puts("No grid information for #{airport.name}")
      else
        # Otherwise, send it to the location pipeline
        IO.puts("Grid information for #{airport.name}")
      end
    end)

    message
  end

  def prepare_messages(messages, _context) do
    Enum.map(messages, &prepare_message/1)
  end

  defp prepare_message(message) do
    [city, state] = String.split(message.data, ",")

    airports = Repo.all(from a in Airport, where: a.city == ^city and a.state == ^state)

    Broadway.Message.put_data(message, airports)
  end
end
