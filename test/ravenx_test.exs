defmodule RavenxTest do
  use ExUnit.Case
  # doctest Ravenx

  alias Ravenx.Strategy.Dummy, as: DummyStrategy

  test "dispatch synchronously :ok notification" do
    result = Ravenx.dispatch(:dummy, %{result: true})

    assert result == DummyStrategy.get_ok_result
  end

  test "dispatch synchronously :error notification" do
    result = Ravenx.dispatch(:dummy, %{result: false})

    assert result == DummyStrategy.get_error_result
  end

  test "dispatch async should return a Task object" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: true})

    assert {:ok, %Task{}} = {status, task}
    assert is_pid(task.pid)
  end

  test "dispatch asynchronously :ok notification" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: true})

    assert {:ok, task} = {status, task}
    assert Task.await(task) == DummyStrategy.get_ok_result
  end

  test "dispatch asynchronously :error notification" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: false})

    assert {:ok, task} = {status, task}
    assert Task.await(task) == DummyStrategy.get_error_result
  end
end
