defmodule Ravenx.Strategy.Slack do
  @moduledoc """
  Ravenx Slack strategy.

  Used to dispatch notifications to Slack service.
  """

  @doc """
  Function used to send a notification to Slack.

  The function receives a `Keyword` list including a `title` and a `body`, and an
  `opts` `Keyword` list that can include this configuration:

  * `url`: URL of Slack integration to call.
  * `username`: Username of the bot used to send the notification.
  * `icon`: Icon to show as the bot avatar (with Slack format, like `:bird:`)
  * `channel`: Channel or username to send the notification.

  It will respond with a tuple, indicating if everything is `:ok` or there was
  an `:error`.

  """
  def call([title: title, body: body], opts \\ []) do
    payload = %{ text: "*#{title}*\n#{body}" }
    |> parse_opts(opts)

    url = opts
    |> Keyword.get(:url)

    send_notification(payload, url)
  end

  # Private function to get options from Keyword received and apply it to the
  # payload.
  #
  defp parse_opts(payload, opts) do
    payload
    |> add_to_payload(:username, Keyword.get(opts, :username))
    |> add_to_payload(:icon_emoji, Keyword.get(opts, :icon))
    |> add_to_payload(:channel, Keyword.get(opts, :channel))
  end

  # Private function to send the notification using HTTPotion client.
  #
  defp send_notification(_payload, nil), do: {:error, "URL not defined"}
  defp send_notification(payload, url) do
    json_payload = Poison.encode!(payload)
    header = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    HTTPotion.start
    case HTTPotion.post(url, [body: json_payload, header: header]) do
      %HTTPotion.Response{body: response, status_code: 200} ->
        {:ok, response}
      %HTTPotion.Response{body: response} ->
        {:error, response}
      _ ->
        {:error, "unknown error"}
    end
  end

  # Private function to add information to the payload.
  #
  defp add_to_payload(payload, _key, nil), do: payload
  defp add_to_payload(payload, key, value) do
    payload
    |> Map.put(key, value)
  end
end