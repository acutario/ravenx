defmodule RavenxNotificationTest do
  use ExUnit.Case

  alias Ravenx.Strategy.Dummy, as: DummyStrategy

  test "dispatch multiple notifications synchronously returns expected keys" do
    result = Ravenx.Test.TestNotification.dispatch(true)

    assert Keyword.has_key?(result, :dummy)
    assert Keyword.has_key?(result, :dummy_not)
  end

  test "dispatch multiple notifications synchronously returns expected results" do
    result = Ravenx.Test.TestNotification.dispatch(true)

    dummy_result = Keyword.get(result, :dummy)
    assert dummy_result == DummyStrategy.get_ok_result

    dummy_not_result = Keyword.get(result, :dummy_not)
    assert dummy_not_result == DummyStrategy.get_error_result
  end

  test "dispatch multiple notifications asynchronously returns expected keys" do
    result = Ravenx.Test.TestNotification.dispatch_async(true)

    assert Keyword.has_key?(result, :dummy)
    assert Keyword.has_key?(result, :dummy_not)
  end

  test "dispatch multiple notifications asynchronously returns expected tasks" do
    result = Ravenx.Test.TestNotification.dispatch_async(true)

    dummy_result = Keyword.get(result, :dummy)
    assert {:ok, %Task{}} = dummy_result

    dummy_not_result = Keyword.get(result, :dummy_not)
    assert {:ok, %Task{}} = dummy_not_result
  end

  test "dispatch multiple notifications asynchronously returns expected results" do
    result = Ravenx.Test.TestNotification.dispatch_async(true)

    {:ok, task} = Keyword.get(result, :dummy)
    assert Task.await(task) == DummyStrategy.get_ok_result

    {:ok, task} = Keyword.get(result, :dummy_not)
    assert Task.await(task) == DummyStrategy.get_error_result
  end
end
