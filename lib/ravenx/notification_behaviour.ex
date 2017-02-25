defmodule Ravenx.NotificationBehaviour do
  @moduledoc """
  Provides an interface for implementations of Ravenx notifications.
  """

  @callback get_notifications_config(any) :: [atom: {atom, map} | {atom, map, map}]
end
