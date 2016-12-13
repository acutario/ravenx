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

      def dispatch_async(opts) do
        opts
        |> get_notifications_list
        |> Enum.map(&Ravenx.Notification.dispatch_async_notification/1)
      end
    end
  end

  @doc """
  Function used to send a notification synchronously using a list with the
  configuration of the notification.

  The list should have this objects:

  1. Strategy atom: defining which strategy to use
  2. Payload map: including the payload data of the notification.
  3. Options map _(optional)_: the special configuration of the notification

  It will respond with a tuple, indicating if everything is `:ok` or there was
  an `:error`.

  """
  def dispatch_notification(notification) do
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

  @doc """
  Function used to send a notification asynchronously using a list with the
  configuration of the notification.

  The list should have this objects:

  1. Strategy atom: defining which strategy to use
  2. Payload map: including the payload data of the notification.
  3. Options map _(optional)_: the special configuration of the notification

  It will respond with a tuple, indicating if everything is `:ok` or there was
  an `:error`.

  """
  def dispatch_async_notification(notification) do
    case notification do
      [strategy, payload, options] when is_atom(strategy) and is_map(payload) and is_map(options) ->
        Ravenx.dispatch_async(strategy, payload, options)
      [strategy, payload] when is_atom(strategy) and is_map(payload) ->
        Ravenx.dispatch_async(strategy, payload)
      [_] ->
        {:error, "Notification config must include, at least, an strategy atom and a payload map."}
      _ ->
        {:error, "Notification config not valid"}
    end
  end
end