defmodule Capstone.MixProject do
  use Mix.Project

  def project do
    [
      app: :capstone,
      version: "0.1.0",
      elixir: "1.14.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      xref: [exclude: [:hackney_request]],
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Capstone.Application, []}
    ]
  end

  defp deps do
    [
      {:amqp, "3.3.0"},
      {:broadway, "1.0.7"},
      {:broadway_rabbitmq, "0.8.0"},
      {:ecto_sql, "3.10.1"},
      {:ex_machina, "2.7.0", only: :test},
      {:exvcr, "0.14.1", only: [:dev, :test]},
      {:faker, "0.17.0"},
      {:flow, "1.2.4"},
      {:jason, "1.4.0"},
      {:mox, "1.0.2", only: :test},
      {:nimble_csv, "1.2.0"},
      {:postgrex, "0.17.1"},
      {:req, "0.3.10"},
      {:timex, "3.7.11"}
    ]
  end

  defp aliases do
    [
      reset: ["vcr.delete --all", "ecto.rollback", "ecto.migrate", "run priv/reset.exs"],
      setup: ["ecto.migrate", "run priv/reset.exs"],
      test: ["ecto.create --quiet", "run priv/reset.exs", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/factory", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
