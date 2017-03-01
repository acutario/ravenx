defmodule Ravenx.Test.TestConfig do

  def test_multiple (payload) do
    %{
      token2: "MySecondSecretToken"
    }
  end

  def test_module (_) do
    %{
      token2: "MySecondSecretToken"
    }
  end
end
