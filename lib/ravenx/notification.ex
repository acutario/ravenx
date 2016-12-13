defmodule Ravenx.Notification do
  @moduledoc """
  Base module for notifications implemented using Ravenx strategies.
  """

  defmacro __using__(_) do
    quote do
      @behaviour Ravenx.NotificationBehaviour

      def dispatch(opts) do
        opts
        |> get_notifications_list
        |> Enum.map(&Ravenx.Notification.dispatch_notification/1)
      end
    end
  end

  def dispatch_notification(notification) when is_list(notification) and length(notification) >=2 do
    case notification do
      [strategy, payload, options] when is_atom(strategy) and is_map(payload) and is_map(options) ->
        Ravenx.dispatch(strategy, payload, options)
      [strategy, payload] when is_atom(strategy) and is_map(payload) ->
        Ravenx.dispatch(strategy, payload)
      [_] ->
        {:error, "Notification config must include, at least, an strategy atom and a payload map."}
      _ ->
        {:error, "Notification config not valid"}
    end
  end
end