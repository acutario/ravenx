defmodule Ravenx do
  @moduledoc """
  Ravenx main module.

  It includes and manages dispatching of messages through registered strategies.
  """

  @type notif_id :: atom
  @type notif_strategy :: atom
  @type notif_payload :: map
  @type notif_options :: map
  @type notif_result :: {:ok, any} | {:error, {atom, any}}
  @type notif_config :: {notif_strategy, notif_payload} |
    {notif_strategy, notif_payload, notif_options}

  @doc """
  Dispatch a notification `payload` to a specified `strategy`.

  Custom options for this call can be passed in `options` parameter.

  Returns a tuple with `:ok` or `:error` indicating the final state.

  ## Examples

      iex> Ravenx.dispatch(:slack, %{title: "Hello world!", body: "Science is cool"})
      {:ok, "ok"}

      iex> Ravenx.dispatch(:wadus, %{title: "Hello world!", body: "Science is cool"})
      {:error, {:unknown_strategy, :wadus}}

  """
  @spec dispatch(notif_strategy, notif_payload, notif_options) :: notif_result
  def dispatch(strategy, payload, options \\ %{}) do
    handler = Keyword.get(available_strategies(), strategy)

    opts = get_options(strategy, payload, options)

    if is_nil(handler) do
      {:error, {:unknown_strategy, strategy}}
    else
      task = Task.async(fn -> handler.call(payload, opts) end)
      Task.await(task)
    end
  end

  @doc """
  Dispatch a notification `payload` to a specified `strategy` asynchronously.

  Custom options for this call can be passed in `options` parameter.

  Returns a tuple with `:ok` or `:error` indicating the task launch result.
  If the result was `:ok`, the Task of the process launched is also returned

  ## Examples

      iex> {status, task} = Ravenx.dispatch_async(:slack, %{title: "Hello world!", body: "Science is cool"})
      {:ok, %Task{owner: #PID<0.165.0>, pid: #PID<0.183.0>, ref: #Reference<0.0.4.418>}}

      iex> Task.await(task)
      {:ok, "ok"}

      iex> Ravenx.dispatch_async(:wadus, %{title: "Hello world!", body: "Science is cool"})
      {:error, {:unknown_strategy, :wadus}}

  """
  @spec dispatch_async(notif_strategy, notif_payload, notif_options) :: notif_result
  def dispatch_async(strategy, payload, options \\ %{}) do
    handler = Keyword.get(available_strategies(), strategy)

    opts = get_options(strategy, payload, options)

    if is_nil(handler) do
      {:error, {:unknown_strategy, strategy}}
    else
      task = Task.async(fn -> handler.call(payload, opts) end)
      {:ok, task}
    end
  end

  @doc """
  Function to get a Keyword list of registered strategies.
  """
  @spec available_strategies() :: keyword
  def available_strategies do
    bundled_strategies = [
      slack: Ravenx.Strategy.Slack,
      email: Ravenx.Strategy.Email
    ]

    bundled_strategies
    |> Keyword.merge(Application.get_env(:ravenx, :strategies, []))
  end

  # Private function to get definitive options keyword list by getting options
  # from three different places.
  #
  @spec get_options(notif_strategy, notif_payload, notif_options) :: notif_options
  defp get_options(strategy, payload, options) do
    # Get strategy configuration in application
    app_config_opts = Enum.into(Application.get_env(:ravenx, strategy, []), %{})

    # Get config module and call the function of this strategy (if any)
    module_name = Application.get_env(:ravenx, :config, nil)
    config_module_opts = call_config_module(module_name, strategy, payload)

    # Merge options
    app_config_opts
    |> Map.merge(config_module_opts)
    |> Map.merge(options)
  end

  # Private function to call the config module if it's defined.
  #
  @spec call_config_module(atom, notif_strategy, notif_payload) :: notif_options
  defp call_config_module(module, _strategy, _payload) when is_nil(module), do: %{}
  defp call_config_module(module, strategy, payload) do
    if Keyword.has_key?(module.__info__(:functions), strategy) do
      apply(module, strategy, [payload])
    else
      %{}
    end
  end

end
