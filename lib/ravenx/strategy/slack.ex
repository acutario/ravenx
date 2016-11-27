defmodule Ravenx.Strategy.Slack do
  def call([title: title, body: body], opts \\ []) do
    payload = %{ text: "*#{title}*\n#{body}" }
    |> parse_opts(opts)

    url = opts
    |> Keyword.get(:url)

    send_notification(payload, url)
  end

  defp parse_opts(payload, opts) do
    payload
    |> add_to_payload(:username, Keyword.get(opts, :username))
    |> add_to_payload(:icon_emoji, Keyword.get(opts, :icon))
    |> add_to_payload(:channel, Keyword.get(opts, :channel))
  end

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

  defp add_to_payload(payload, _key, nil), do: payload
  defp add_to_payload(payload, key, value) do
    payload
    |> Map.put(key, value)
  end
end