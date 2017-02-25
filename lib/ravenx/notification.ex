defmodule Ravenx.Notification do
  @moduledoc """
  Base module for notifications implemented using Ravenx strategies.
  """

  @doc """
  Macro to inject notification features in application's modules.
  """
  defmacro __using__(_) do
    quote do
      # Notification implementations should implement required callbacks.
      @behaviour Ravenx.NotificationBehaviour

      @doc """
      Function dispatch the notification synchronously.

      The object received will be used as the `get_notifications_config` argument,
      which should return a keyword list of notification configs that have the
      notification IDs as keys and the configuration tuple as value.

      It will respond with a keyword list that have the notification IDs as keys,
      and a tuple indicating final state as value.
      That tuple follows standard notification dispatch response.

      """
      @spec dispatch(any) :: [atom: {:ok, any} | {:error, {atom, any}}]
      def dispatch(opts) do
        opts
        |> get_notifications_config
        |> Enum.map(fn(k, opts) -> {k, Ravenx.Notification.dispatch_notification(opts)} end)
      end

      @doc """
      Function dispatch the notification asynchronously.

      The object received will be used as the `get_notifications_config` argument,
      which should return a keyword list of notification configs that have the
      notification IDs as keys and the configuration tuple as value.

      It will respond with a keyword list that have the notification IDs as keys,
      and a tuple indicating final state as value.
      That tuple follows standard notification dispatch response.

      """
      @spec dispatch_async(any) :: [atom: {:ok, any} | {:error, {atom, any}}]
      def dispatch_async(opts) do
        opts
        |> get_notifications_config
        |> Enum.map(fn(k, opts) -> {k, Ravenx.Notification.dispatch_async_notification(opts)} end)
      end
    end
  end

  @doc """
  Function used to send a notification synchronously using a configuration tuple
  like the ones that `get_notifications_config` should return.

  The tuple should have this objects:

  1. Strategy atom: defining which strategy to use
  2. Payload map: including the payload data of the notification.
  3. Options map _(optional)_: the special configuration of the notification

  It will respond with a tuple, with an atom that could be `:ok` or `:error` and
  the result of the operation, as an standard notification dispatch returns.

  """
  @spec dispatch_notification({atom, map, map} | {atom, map}) :: {:ok, any} | {:error, {atom, any}}
  def dispatch_notification(notification) do
    case notification do
      {strategy, payload, options} when is_atom(strategy) and is_map(payload) and is_map(options) ->
        Ravenx.dispatch(strategy, payload, options)
      {strategy, payload} when is_atom(strategy) and is_map(payload) ->
        Ravenx.dispatch(strategy, payload)
      [_] ->
        {:error, {:missing, :payload}}
      _ ->
        {:error, {:invalid, :notification}}
    end
  end

  @doc """
  Function used to send a notification synchronously using a configuration tuple
  like the ones that `get_notifications_config` should return.

  The tuple should have this objects:

  1. Strategy atom: defining which strategy to use
  2. Payload map: including the payload data of the notification.
  3. Options map _(optional)_: the special configuration of the notification

  It will respond with a tuple, with an atom that could be `:ok` or `:error` and
  the result of the operation, as an standard notification dispatch returns.

  """
  @spec dispatch_async_notification({atom, map, map} | {atom, map}) :: {:ok, any} | {:error, {atom, any}}
  def dispatch_async_notification(notification) do
    case notification do
      {strategy, payload, options} when is_atom(strategy) and is_map(payload) and is_map(options) ->
        Ravenx.dispatch_async(strategy, payload, options)
      {strategy, payload} when is_atom(strategy) and is_map(payload) ->
        Ravenx.dispatch_async(strategy, payload)
      [_] ->
        {:error, {:missing, :payload}}
      _ ->
        {:error, {:invalid, :notification}}
    end
  end
end