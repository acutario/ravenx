# Ravenx

Notification dispatch library for Elixir applications (WIP).

## Single notification

Sending a single notification is as simply as calling this method:

```elixir
iex> Ravenx.dispatch(strategy, payload)
```

In which `stratey` is an atom indicating one of the defined strategies and the
`payload` is a map with information to dispatch the notification.

For example:

```elixir
iex> Ravenx.dispatch(:slack, %{title: "Hello world!", body: "Science is cool!"})
```

Optionally, a third parameter containing a map of options (like URLs or
secrets) can be passed.

## Multiple notifications

You can implement notification modules taht will tell `Ravenx` which strategies should use to send a specific notification.

To do it, you just need to `use Ravenx.Notification` and implement a callback function:

```elixir
defmodule YourApp.Notification.NotifyUser do
  use Ravenx.Notification

  def get_notifications_list(user) do
    # In this function you can define which strategies use for your user (or
    # whatever you want to pass as argument) and return something like:

    [
      [:slack, %{title: "Important notification!", body: "Wait..."}, %{channel: user.slack_username}],
      [:email, %{subject: "Important notification!", html_body: "<h1>Wait...</h1>", to: user.email_address}],
      [:wadus, %{text: "Important notification!"}, %{option1: value2}],
    ]
  end
end
```

Strategies can be used multiple times in a notification list (for example, if you want to notify multiple users via Slack).

**Note:** each notification entry in the returned list should include:

1. Atom defining which strategy should be used.
2. Payload map with the data of the notification.
3. Optional options map for that specific notification.

And then you can dispatch your notification using:

```elixir
iex> YourApp.Notification.NotifyUser.dispatch(user)
```

or asynchronously:

```elixir
iex> YourApp.Notification.NotifyUser.dispatch_async(user)
```

Both will return a list with the responses for each notification sent.

## Configuration
Strategies usually needs configuration options. To solve that, there are three
ways in which you can configure a notification dispatch strategy:

1. Passing the options in the dispatch call:

```elixir
iex> Ravenx.dispatch(:slack, %{title: "Hello world!", body: "Science is cool!"}, %{url: "...", icon: ":bird:"})
```

2. Specifying a configuration module in your application config:

```elixir
config :ravenx,
  config: YourApp.RavenxConfig
```

and creating that module:

```elixir
defmodule YourApp.RavenxConfig do
  def slack (_payload) do
    %{
      url: "...",
      icon: ":bird:"
    }
  end
end
```

**Note:** the module should contain a function called as the strategy yopu are
configuring, receiving the payload and returning a configuration Keyword list.

3. Specifying the configuration directly on your application config file:

```elixir
config :ravenx,
  slack: %{
    url: "...",
    icon: ":bird:"
  }
```

### Mixing configurations
Configuration can also be mixed by using the three methods:

 * Static configuration on application configuration.
 * Dynamic configuration common to more than one scenario using a configuration module.
 * Call-specific configuration sending a config Keyword list on `dispatch` method.