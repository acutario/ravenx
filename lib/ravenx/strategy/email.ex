defmodule Ravenx.Strategy.Email do
  @moduledoc """
  Ravenx Email strategy.

  Used to dispatch notifications via email.
  """

  @doc """
  Function used to send a notification via email.

  TODO: Add extra doc about config

  It will respond with a tuple, indicating if everything is `:ok` or there was
  an `:error`.

  """
  def call([subject: _s, text_body: _tb, from: _f, to: _t]=payload, opts \\ []) do
    email = %Bamboo.Email{}
    |> parse_payload(payload)

    send_email(email, opts)
  end

  # Priate function to handle email sending and verify that required fields are
  # passed
  defp send_email(%Bamboo.Email{from: _f, to: _t} = email, %{adapter: adapter} = opts) do

  end
  defp send_email(_email, %{adapter: _adapter}), do: {:error, "Missing 'from' or 'to' addresses"}
  defp send_email(_email, _opts), do: {:error, "Missing adapter configuration"}

  # Private function to get information from payload and apply to the Bamboo
  # email object.
  #
  defp parse_payload(email, payload) do
    email
    |> add_to_email(:subject, Keyword.get(payload, :subject))
    |> add_to_email(:from, Keyword.get(payload, :from))
    |> add_to_email(:to, Keyword.get(payload, :to))
    |> add_to_email(:cc, Keyword.get(payload, :cc))
    |> add_to_email(:bcc, Keyword.get(payload, :bcc))
    |> add_to_email(:text_body, Keyword.get(payload, :text_body))
    |> add_to_email(:html_body, Keyword.get(payload, :html_body))
  end

  # Private function to add information to the email object.
  #
  defp add_to_email(email, _key, nil), do: email
  defp add_to_email(email, key, value) do
    email
    |> Map.put(key, value)
  end

  defp available_adapters() do
    [
      mailgun: Bamboo.MailgunAdapter,
      mandrill: Bamboo.MandrillAdapter,
      sendgrid: Bamboo.SendgridAdapter,
      local: Bamboo.LocalAdapter,
      tesst: Bamboo.TestAdapter
    ]
  end
end