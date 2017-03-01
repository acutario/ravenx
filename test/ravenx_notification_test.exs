defmodule RavenxNotificationTest do
  use ExUnit.Case

  test "dispatch multiple notifications synchronously returns expected keys" do
    result = Ravenx.Test.TestNotification.dispatch(true)

    assert Keyword.has_key?(result, :dummy)
    assert Keyword.has_key?(result, :dummy_not)
  end

  test "dispatch multiple notifications synchronously returns expected results" do
    result = Ravenx.Test.TestNotification.dispatch(true)

    dummy_result = Keyword.get(result, :dummy)
    assert {:ok, true} = dummy_result

    dummy_not_result = Keyword.get(result, :dummy_not)
    assert {:error, payload} = dummy_not_result
    assert {:expected_error, false} = payload
  end
end
