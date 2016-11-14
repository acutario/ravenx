defmodule Ravenx do

  def dispatch(strategy, [title: _t, short_body: _sb, body: _b] = payload, options \\ []) do
    handler = available_strategies
    |> Keyword.get(strategy)

    unless (is_nil(handler)) do
      Task.async(fn -> handler.call(payload, options) end)
      |> Task.await()
    else
      {:error, "#{strategy} strategy not defined"}
    end
  end

  def dispatch_async(strategy, [title: _t, short_body: _sb, body: _b] = payload, options \\ []) do
    handler = available_strategies
    |> Keyword.get(strategy)

    unless (is_nil(handler)) do
      pid = Task.async(fn -> handler.call(payload, options) end)
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
end
