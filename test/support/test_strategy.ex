defmodule Ravenx.Test.TestStrategy do
  @moduledoc """
  Ravenx Test strategy.

  Used to test dispatching notifications.
  """

  @behaviour Ravenx.StrategyBehaviour

  @doc """
  Function used to send a notification.

  This is a dummy one: if it receives a payload with result equal to true, returns
  true. Otherwise, return false.

  """
  @spec call(map, map) :: {:ok, Bamboo.Email.t} | {:error, {atom, any}}
  def call(%{result: true}, _opts), do: {:ok, true}
  def call(payload, _opts), do: {:error, {:expected_error, false}}
end
