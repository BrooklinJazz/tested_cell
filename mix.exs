defmodule TestedCell.MixProject do
  use Mix.Project

  def project do
    [
      app: :tested_cell,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TestedCell.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:makeup, "~> 1.1.0"},
      {:makeup_elixir, "~> 0.16.0"},
      {:kino, github: "livebook-dev/kino", override: true}
    ]
  end
end
