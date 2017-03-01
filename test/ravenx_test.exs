defmodule RavenxTest do
  use ExUnit.Case
  # doctest Ravenx

  test "dispatch synchronously :ok notification" do
    {status, result} = Ravenx.dispatch(:dummy, %{result: true})

    assert {:ok, true} = {status, result}
  end

  test "dispatch synchronously :error notification" do
    {status, result} = Ravenx.dispatch(:dummy, %{result: false})

    assert {:error, result} = {status, result}
    assert {:expected_error, false} = result
  end

  test "dispatch async should return a Task object" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: true})

    assert {:ok, %Task{}} = {status, task}
    assert is_pid(task.pid)
  end

  test "dispatch asynchronously :ok notification" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: true})

    assert {:ok, task} = {status, task}
    assert {:ok, true} = Task.await(task)
  end

  test "dispatch asynchronously :error notification" do
    {status, task} = Ravenx.dispatch_async(:dummy, %{result: false})

    assert {:ok, task} = {status, task}
    assert {:error, {:expected_error, false}} = Task.await(task)
  end
end
