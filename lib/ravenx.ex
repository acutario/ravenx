defmodule Ravenx do

  def dispatch(strategy, [title: _t, body: _b] = payload, options \\ []) do
    handler = available_strategies
    |> Keyword.get(strategy)

    opts = get_options(strategy, payload, options)

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

    opts = get_options(strategy, payload, options)

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


  defp get_options(strategy, payload, options) do
    app_config_opts = Application.get_env(:ravenx, strategy, [])

    config_module_opts = Application.get_env(:ravenx, :config, nil)
    |> call_config_module(strategy, payload)

    app_config_opts
    |> Keyword.merge(config_module_opts)
    |> Keyword.merge(options)
  end

  defp call_config_module(module, _strategy, _payload) when is_nil(module), do: []
  defp call_config_module(module, strategy, payload) do
    apply(module, strategy, [payload])
  end

end
