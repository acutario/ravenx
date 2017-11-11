defmodule Ravenx.Supervisor do
  @moduledoc """
  Supervises notification dispatch processes.
  """
  use Supervisor

  def start_link() do
    Task.Supervisor.start_link(name: __MODULE__)
  end
end
