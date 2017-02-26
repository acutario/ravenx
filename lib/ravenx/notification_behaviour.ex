defmodule Ravenx.NotificationBehaviour do
  @moduledoc """
  Provides an interface for implementations of Ravenx notifications.
  """

  @callback get_notifications_config(any) :: [{Ravenx.notification_id, Ravenx.notification_config}]
end
