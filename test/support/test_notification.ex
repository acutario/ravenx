defmodule Ravenx.Test.TestNotification do
  use Ravenx.Notification

  @doc """
  Test notification that delivers a dummy notification with the expected result
  and one with the opposite.
  """

  def get_notifications_config(result) when is_boolean(result) do
    [
      dummy: {:dummy, %{result: result}},
      dummy_not: {:dummy, %{result: !result}}
    ]
  end
end
