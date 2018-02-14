defmodule RavenxTest do
  use ExUnit.Case

  alias Ravenx.Strategy.Dummy, as: DummyStrategy

  test "dispatch synchronously with unknown strategy will return error" do
    result = Ravenx.dispatch(:wadus, %{})

    assert result == {:error, {:unknown_strategy, :wadus}}
  end

  test "dispatch asynchronously with unknown strategy will return error" do
    result = Ravenx.dispatch_async(:wadus, %{})

    assert result == {:error, {:unknown_strategy, :wadus}}
  end

  test "dispatch unlinked with unknown strategy will return error" do
    result = Ravenx.dispatch_nolink(:wadus, %{})

    assert result == {:error, {:unknown_strategy, :wadus}}
  end

  test "dispatch synchronously :ok notification" do
    result = Ravenx.dispatch(:dummy, %{result: true})

    assert result == DummyStrategy.get_ok_result()
  end

  test "dispatch synchronously :error notification" do
    result = Ravenx.dispatch(:dummy, %{result: false})

    assert result == DummyStrategy.get_error_result()
  end

  test "dispatch async should return a Task object" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: true})

    assert {:ok, %Task{}} = {status, task}
    assert is_pid(task.pid)
  end

  test "dispatch unlink should return a PID" do
    {:ok, pid} = Ravenx.dispatch_nolink(:dummy, %{result: true})

    assert is_pid(pid)
  end

  test "dispatch asynchronously :ok notification" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: true})

    assert {:ok, task} = {status, task}
    assert Task.await(task) == DummyStrategy.get_ok_result()
  end

  test "dispatch asynchronously :error notification" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: false})

    assert {:ok, task} = {status, task}
    assert Task.await(task) == DummyStrategy.get_error_result()
  end

  test "custom strategies can be added using configuration" do
    strategies = Application.get_env(:ravenx, :strategies, [])
    available_strategies = Ravenx.available_strategies()

    strategies
    |> Keyword.keys()
    |> Enum.each(fn strategy -> assert Keyword.has_key?(available_strategies, strategy) end)
  end

  test "test custom runtime options in configuration" do
    configuration = %{foo: "bar"}

    {:ok, result} = Ravenx.dispatch(:test, %{}, configuration)

    assert configuration == result
  end

  test "test custom options in configuration" do
    configuration =
      Application.get_env(:ravenx, :test_config, [])
      |> Enum.into(%{})

    {:ok, result} = Ravenx.dispatch(:test_config, %{}, %{})

    assert configuration == result
  end

  test "test custom options in module" do
    configuration = Ravenx.Test.TestConfig.test_module(%{})
    {:ok, result} = Ravenx.dispatch(:test_module, %{}, %{})

    assert configuration == result
  end

  test "test custom multiple options in module" do
    # Get config from the three possible vias
    runtime_config = %{foo: "bar"}

    app_config =
      Application.get_env(:ravenx, :test_multiple, [])
      |> Enum.into(%{})

    module_config = Ravenx.Test.TestConfig.test_multiple(%{})

    # Merge them
    configuration =
      runtime_config
      |> Map.merge(app_config)
      |> Map.merge(module_config)

    # Call and check the result
    {:ok, result} = Ravenx.dispatch(:test_multiple, %{}, runtime_config)
    assert configuration == result
  end
end
