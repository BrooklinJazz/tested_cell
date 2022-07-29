defmodule TestedCell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {TestedCell.Control, []}
    ]

    Kino.SmartCell.register(TestedCell)

    opts = [strategy: :one_for_one, name: TestedCell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
