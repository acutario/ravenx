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

      alias Ravenx.Notification

      @doc """
      Function dispatch the notification synchronously.

      The object received will be used as the `get_notifications_config` argument,
      which should return a keyword list of notification configs that have the
      notification IDs as keys and the configuration tuple as value.

      It will respond with a keyword list that have the notification IDs as keys,
      and a tuple indicating final state as value.
      That tuple follows standard notification dispatch response.

      """
      @spec dispatch(any) :: [{Ravenx.notif_id(), Ravenx.notif_result()}]
      def dispatch(opts) do
        opts
        |> get_notifications_config
        |> Enum.map(fn {k, opts} ->
          {k, Notification.dispatch_notification(opts, :sync)}
        end)
      end

      @doc """
      Function dispatch the notification asynchronously and linked.

      Notifications dispatched with this function are linked to their caller processes. If you are
      not interested in the result of the notification dispatch you should use `dispatch_nolink/1`.

      The object received will be used as the `get_notifications_config` argument,
      which should return a keyword list of notification configs that have the
      notification IDs as keys and the configuration tuple as value.

      It will respond with a keyword list that have the notification IDs as keys,
      and a tuple indicating final state as value.
      That tuple follows standard notification dispatch response.

      """
      @spec dispatch_async(any) :: [{Ravenx.notif_id(), Ravenx.notif_result()}]
      def dispatch_async(opts) do
        opts
        |> get_notifications_config
        |> Enum.map(fn {k, opts} ->
          {k, Notification.dispatch_notification(opts, :async)}
        end)
      end

      @doc """
      Function dispatch the notification asynchronously and unlinked.

      Notifications dispatched with this function are not linked to their caller processes. If you
      are interested in the result of the notification dispatch you should use `dispatch_async/1`.

      The object received will be used as the `get_notifications_config` argument,
      which should return a keyword list of notification configs that have the
      notification IDs as keys and the configuration tuple as value.

      It will respond with a keyword list that have the notification IDs as keys,
      and a tuple indicating final state as value.
      That tuple follows standard notification dispatch response.
      """
      @spec dispatch_nolink(any) :: [{Ravenx.notif_id(), Ravenx.notif_result()}]
      def dispatch_nolink(opts) do
        opts
        |> get_notifications_config
        |> Enum.map(fn {k, opts} ->
          {k, Notification.dispatch_notification(opts, :nolink)}
        end)
      end
    end
  end

  @doc """
  Function used to send a using a configuration tuple like the ones that `get_notifications_config`
  should return.

  The tuple should have this objects:

  1. Strategy atom: defining which strategy to use
  2. Payload map: including the payload data of the notification.
  3. Options map _(optional)_: the special configuration of the notification

  It will respond with a tuple, with an atom that could be `:ok` or `:error` and
  the result of the operation, as an standard notification dispatch returns.
  """
  @spec dispatch_notification(Ravenx.notif_config(), Ravenx.dispatch_type()) ::
          Ravenx.notif_result()
  def dispatch_notification(notification, dispatch_type) do
    dispatcher = get_dispatcher(dispatch_type)

    case notification do
      {strategy, payload, options} when is_atom(strategy) and is_map(payload) and is_map(options) ->
        dispatcher.(strategy, payload, options)

      {strategy, payload} when is_atom(strategy) and is_map(payload) ->
        dispatcher.(strategy, payload, %{})

      [_] ->
        {:error, {:missing, :payload}}

      _ ->
        {:error, {:invalid, :notification}}
    end
  end

  defp get_dispatcher(:sync), do: &Ravenx.dispatch/3
  defp get_dispatcher(:async), do: &Ravenx.dispatch_async/3
  defp get_dispatcher(:nolink), do: &Ravenx.dispatch_nolink/3
end
