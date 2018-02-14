defmodule Ravenx.Strategy.Dummy do
  @moduledoc """
  Ravenx Dummy strategy.

  Used to avoid dispatching real notifications.
  """

  @behaviour Ravenx.StrategyBehaviour

  @doc """
  Function used to send a notification.

  This is a dummy one: if it receives a payload with result equal to true, returns
  true. Otherwise, return false.

  """
  @spec call(map, map) :: {:ok, Bamboo.Email.t()} | {:error, {atom, any}}
  def call(%{result: true}, _), do: get_ok_result()
  def call(_, _), do: get_error_result()

  def get_ok_result, do: {:ok, true}
  def get_error_result, do: {:error, {:expected_error, false}}
end
