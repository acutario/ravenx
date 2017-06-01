defmodule Ravenx.Strategy.Email do
  @moduledoc """
  Ravenx Email strategy.

  Used to dispatch notifications via email.
  """

  @behaviour Ravenx.StrategyBehaviour

  alias Bamboo.Mailer

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
  @spec call(map, %{adapter: atom}) :: {:ok, Bamboo.Email.t} | {:error, {atom, any}}
  def call(payload, %{adapter: _a} = opts) do
    %Bamboo.Email{}
    |> parse_options(opts)
    |> parse_payload(payload)
    |> send_email(opts)
  end
  def call(_payload, _opts), do: {:error, {:missing_config, :adapter}}

  # It returns a list of available adapters.
  #
  @spec available_adapters() :: keyword
  def available_adapters do
    default_adapters =
      [
        mailgun: Bamboo.MailgunAdapter,
        mandrill: Bamboo.MandrillAdapter,
        sendgrid: Bamboo.SendgridAdapter,
        smtp: Bamboo.SMTPAdapter,
        local: Bamboo.LocalAdapter,
        test: Bamboo.TestAdapter
      ]
    Keyword.merge(default_adapters, Application.get_env(:ravenx, :bamboo_adapters) ||  [])
  end

  # Tries to get an adapter form list of available adapters
  #
  @spec available_adapter(atom) :: {:ok, atom} | {:error, nil}
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
  @spec send_email(Bamboo.Email.t, map) :: {:ok, Bamboo.Email.t} | {:error, {atom, any}}

  defp send_email(%Bamboo.Email{to: nil}, _opts), do: {:error, {:missing_config, :to}}
  defp send_email(%Bamboo.Email{from: nil}, _opts), do: {:error, {:missing_config, :from}}

  defp send_email(%Bamboo.Email{} = email, opts) do
    adapter = opts
    |> Map.get(:adapter)
    |> available_adapter()

    case adapter do
      {:ok, adapter} ->
        try do
          # We must tell the adapter to fulfill the options
          complete_opts = opts
          |> adapter.handle_config()

          response = Mailer.deliver_now(adapter, email, complete_opts)
          {:ok, response}
        rescue
          e -> {:error, {:exception, e}}
        end
      {:error, _} ->
        {:error, {:adapter_not_found, adapter}}
    end
  end

  defp send_email(_email, _opts), do: {:error, {:unknown_error, nil}}

  # Private function to get information from payload and apply to the Bamboo
  # email object.
  #
  @spec parse_payload(Bamboo.Email.t, map()) :: Bamboo.Email.t
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
  @spec add_to_email(Bamboo.Email.t, atom, any) :: Bamboo.Email.t
  defp add_to_email(email, _key, nil), do: email
  defp add_to_email(email, key, value) do
    email
    |> Map.put(key, value)
  end
end
