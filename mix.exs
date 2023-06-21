defmodule Capstone.MixProject do
  use Mix.Project

  def project do
    [
      app: :capstone,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Capstone.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "1.0.7"},
      {:broadway_kafka, "0.4.1"},
      {:ecto_sql, "3.10.1"},
      {:flow, "1.2.4"},
      {:postgrex, "0.17.1"},
      {:req, "0.3.10"}
    ]
  end
end
