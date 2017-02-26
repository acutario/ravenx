defmodule Ravenx.Strategy.Slack do
  @moduledoc """
  Ravenx Slack strategy.

  Used to dispatch notifications to Slack service.
  """

  @behaviour Ravenx.StrategyBehaviour

  @doc """
  Function used to send a notification to Slack.

  The function receives a map including a `title` and a `body`, and an
  `options` Mmp that can include this configuration:

  * `url`: URL of Slack integration to call.
  * `username`: Username of the bot used to send the notification.
  * `icon`: Icon to show as the bot avatar (with Slack format, like `:bird:`)
  * `channel`: Channel or username to send the notification.

  It will respond with a tuple, indicating if everything was `:ok` or there was
  an `:error`.

  """
  @spec call(%{title: binary, body: binary}, map) :: {:ok, binary} | {:error, {atom, any}}
  def call(%{title: title, body: body}, options \\ %{}) do
    payload = %{text: "*#{title}*\n#{body}"}
    |> parse_options(options)

    url = options
    |> Map.get(:url)

    send_notification(payload, url)
  end

  # Private function to get options from Keyword received and apply it to the
  # payload.
  #
  @spec parse_options(map, map) :: map
  defp parse_options(payload, options) do
    payload
    |> add_to_payload(:username, Map.get(options, :username))
    |> add_to_payload(:icon_emoji, Map.get(options, :icon))
    |> add_to_payload(:channel, Map.get(options, :channel))
  end

  # Private function to send the notification using HTTPotion client.
  #
  @spec send_notification(map, binary) :: {:ok, binary} | {:error, {atom, any}}
  defp send_notification(_payload, nil), do: {:error, {:missing_config, :url}}
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
        {:error, {:error_response, response}}
      _ = e ->
        {:error, {:unknown_response, e}}
    end
  end

  # Private function to add information to the payload.
  #
  @spec add_to_payload(map, atom, any) :: map
  defp add_to_payload(payload, _key, nil), do: payload
  defp add_to_payload(payload, key, value) do
    payload
    |> Map.put(key, value)
  end
end
