defmodule Ravenx.Strategy.Email do
  @moduledoc """
  Ravenx Email strategy.

  Used to dispatch notifications via email.
  """

  @doc """
  Function used to send a notification via email.

  It receives two maps, containing the payload and options.

  The payload can include this keys:

  * `from`: (required) the email address from which the email is sent.
  * `to`: (required) a list of email addresses that will receive the email.
  * `cc`: a list of email addresses that will receive a copy of the email.
  * `bcc`: a list of email addresses that will receive a hidden copy of the email.
  * `subject`: the subject of the e-mail.
  * `text_body`: the text version of the message.
  * `html_body`: that HTML version of the message.

  In the options map there must be an `adapter` key indicating one of
  the available adapters, and also the configuration required for each adapter.

  It will respond with a tuple, indicating if everything is `:ok` or there was
  an `:error`.

  """
  @spec call(map, map) :: {atom, any}
  def call(payload, opts \\ %{}) do
    %Bamboo.Email{}
    |> parse_options(options)
    |> parse_payload(payload)
    |> send_email(opts)
  end

  # It returns a list of available adapters.
  #
  @spec available_adapters() :: keyword
  def available_adapters() do
    [
      mailgun: Bamboo.MailgunAdapter,
      mandrill: Bamboo.MandrillAdapter,
      sendgrid: Bamboo.SendgridAdapter,
      smtp: Bamboo.SMTPAdapter,
      local: Bamboo.LocalAdapter,
      test: Bamboo.TestAdapter
    ]
  end

  # Tries to get an adapter form list of available adapters
  #
  @spec available_adapter(atom) :: {atom, any}
  defp available_adapter(adapter) do
    case Keyword.get(available_adapters(), adapter, nil) do
      nil ->
        {:error, nil}
      adapter ->
        {:ok, adapter}
    end
  end

  # Priate function to handle email sending and verify that required fields are
  # passed
  defp send_email(%Bamboo.Email{from: _f, to: _t} = email, %{ adapter: adapter } = opts) do
    case available_adapter(adapter) do
      {:ok, adapter} ->
        try do
          # We must tell the adapter to fulfill the options
          complete_opts = opts
          |> adapter.handle_config()

          response = Bamboo.Mailer.deliver_now(adapter, email, complete_opts)
          # If everything went well, just answer with OK
          {:ok, response}
        rescue
          # If there is an exception, return it as an error
          e -> {:error, e}
        end
      {:error, _} ->
        {:error, "Adapter not found: '#{adapter}'"}
    end
  end
  defp send_email(_email, %{ adapter: _adapter }), do: {:error, "Missing 'from' or 'to' addresses"}
  defp send_email(_email, _opts), do: {:error, "Missing adapter configuration"}

  # Private function to get information from payload and apply to the Bamboo
  # email object.
  #
  defp parse_payload(email, payload) do
    email
    |> add_to_email(:subject, Map.get(payload, :subject))
    |> add_to_email(:from, Map.get(payload, :from))
    |> add_to_email(:to, Map.get(payload, :to))
    |> add_to_email(:cc, Map.get(payload, :cc))
    |> add_to_email(:bcc, Map.get(payload, :bcc))
    |> add_to_email(:text_body, Map.get(payload, :text_body))
    |> add_to_email(:html_body, Map.get(payload, :html_body))
  end

  # Private function to get information from options and apply to the Bamboo
  # email object.
  #
  defp parse_options(email, options) do
    email
    |> add_to_email(:subject, Map.get(options, :subject))
    |> add_to_email(:from, Map.get(options, :from))
    |> add_to_email(:to, Map.get(options, :to))
    |> add_to_email(:cc, Map.get(options, :cc))
    |> add_to_email(:bcc, Map.get(options, :bcc))
  end

  # Private function to add information to the email object.
  #
  defp add_to_email(email, _key, nil), do: email
  defp add_to_email(email, key, value) do
    email
    |> Map.put(key, value)
  end
end