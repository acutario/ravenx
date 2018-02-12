defmodule Ravenx.StrategyBehaviour do
  @moduledoc """
  Provides an interface for implementations of Ravenx strategies.
  """

  @callback call(Ravenx.notif_payload(), Ravenx.notif_options()) :: Ravenx.notif_result()
end
