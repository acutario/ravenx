defmodule Ravenx do

  def dispatch(strategy, [title: _t, body: _b] = payload, options \\ []) do
    handler = available_strategies
    |> Keyword.get(strategy)

    opts = options
    |> merge_options(strategy)

    unless (is_nil(handler)) do
      Task.async(fn -> handler.call(payload, opts) end)
      |> Task.await()
    else
      {:error, "#{strategy} strategy not defined"}
    end
  end

  def dispatch_async(strategy, [title: _t, body: _b] = payload, options \\ []) do
    handler = available_strategies
    |> Keyword.get(strategy)

    opts = options
    |> merge_options(strategy)

    unless (is_nil(handler)) do
      pid = Task.async(fn -> handler.call(payload, opts) end)
      {:ok, pid}
    else
      {:error, "#{strategy} specified not defined"}
    end
  end

  def available_strategies() do
    [
      slack: Ravenx.Strategy.Slack
    ]
  end

  def merge_options(opts, strategy) do
    Application.get_env(:ravenx, strategy, [])
    |> Keyword.merge(opts)
  end
end
