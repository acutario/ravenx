defmodule Ravenx do
  @moduledoc """
  Ravenx main module.

  It includes and manages dispatching of messages through registered strategies.
  """

  @doc """
  Dispatch a notification `payload` to a specified `strategy`.

  Custom options for this call can be passed in `options` parameter.

  Returns a tuple with `:ok` or `:error` indicating the final state.

  ## Examples

      iex> Ravenx.dispatch(:slack, %{title: "Hello world!", body: "Science is cool"})
      {:ok, "ok"}

      iex> Ravenx.dispatch(:wadus, %{title: "Hello world!", body: "Science is cool"})
      {:error, "wadus strategy not defined"}

  """
  @spec dispatch(atom, map, map) :: {:ok, any} | {:error, {atom, any}}
  def dispatch(strategy, payload, options \\ %{}) do
    handler = available_strategies
    |> Keyword.get(strategy)

    opts = get_options(strategy, payload, options)

    unless (is_nil(handler)) do
      Task.async(fn -> handler.call(payload, opts) end)
      |> Task.await()
    else
      {:error, {:unknown_strategy, strategy}}
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
      {:error, "wadus strategy not defined"}

  """
  @spec dispatch_async(atom, map, map) :: {:ok, any} | {:error, {atom, any}}
  def dispatch_async(strategy, payload, options \\ %{}) do
    handler = available_strategies
    |> Keyword.get(strategy)

    opts = get_options(strategy, payload, options)

    unless (is_nil(handler)) do
      task = Task.async(fn -> handler.call(payload, opts) end)
      {:ok, task}
    else
      {:error, {:unknown_strategy, strategy}}}
    end
  end

  @doc """
  Function to get a Keyword list of registered strategies.
  """
  @spec available_strategies() :: keyword
  def available_strategies() do
    [
      slack: Ravenx.Strategy.Slack,
      email: Ravenx.Strategy.Email
    ]
  end

  # Private function to get definitive options keyword list by getting options
  # from three different places.
  #
  defp get_options(strategy, payload, options) do
    # Get strategy configuration in application
    app_config_opts = Application.get_env(:ravenx, strategy, [])
    |> Enum.into(%{})

    # Get config module and call the function of this strategy (if any)
    config_module_opts = Application.get_env(:ravenx, :config, nil)
    |> call_config_module(strategy, payload)

    # Merge options
    app_config_opts
    |> Map.merge(config_module_opts)
    |> Map.merge(options)
  end

  # Private function to call the config module if it's defined.
  #
  defp call_config_module(module, _strategy, _payload) when is_nil(module), do: %{}
  defp call_config_module(module, strategy, payload) do
    if (Keyword.has_key?(module.__info__(:functions), strategy)) do
      apply(module, strategy, [payload])
    else
      %{}
    end
  end

end
