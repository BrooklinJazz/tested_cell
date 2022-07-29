defmodule TestedCell.Control do
  @moduledoc """
  Control

  Controls TestedCell settings
  """
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{display_editors: false, max_attempts: 3} end, name: __MODULE__)
  end

  @doc """
  Check if editors are enabled.
  """
  def editors_enabled? do
    Agent.get(__MODULE__, fn state -> state.display_editors end)
  end

  @doc """
  Check the max number of attempts before displaying a solution.

  ## Examples

    iex> TestedCell.Control.max_attempts()
    3
  """
  def max_attempts do
    Agent.get(__MODULE__, fn state -> state.max_attempts end)
  end

  @doc """
  Show text editors

  ## Examples

    iex> TestedCell.Control.show_editors()
    iex> TestedCell.Control.editors_enabled?()
    true
  """
  def show_editors do
    Agent.update(__MODULE__, fn state -> Map.put(state, :display_editors, true) end)
  end

  @doc """
  Set maximum number of attempts before displaying the solution

  ## Examples

    iex> TestedCell.Control.set_max_attempts(5)
    iex> TestedCell.Control.max_attempts()
    5
  """
  def set_max_attempts(int) when is_integer(int) do
    Agent.update(__MODULE__, fn state -> Map.put(state, :max_attempts, int) end)
  end
end
