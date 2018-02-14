defmodule Ravenx.Test.TestStrategy do
  @moduledoc """
  Ravenx Test strategy.

  Used to test if configuration is read.
  """

  @behaviour Ravenx.StrategyBehaviour

  @doc """
  Function used to send a notification.

  This is a dummy one: if it receives a payload with result equal to true, returns
  true. Otherwise, return false.

  """
  @spec call(map, map) :: {:ok, Bamboo.Email.t()} | {:error, {atom, any}}
  def call(_, opts), do: {:ok, opts}
end
