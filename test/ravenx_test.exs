defmodule RavenxTest do
  use ExUnit.Case
  # doctest Ravenx

  test "dispatch simple :ok notification" do
    {status, result} = Ravenx.dispatch(:test, %{result: true})

    assert {:ok, true} = {status, result}
  end
end
