# Ravenx


[![Current Version](https://img.shields.io/hexpm/v/ravenx.svg)](https://hex.pm/packages/ravenx)
[![Build Status](https://travis-ci.org/acutario/ravenx.svg?branch=master)](https://travis-ci.org/acutario/ravenx)

Notification dispatch library for Elixir applications (WIP).

## Installation

1. The package can be installed as simply as adding `ravenx` to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [{:ravenx, "~> 1.1.3"}]
  end
```

2. Add Ravenx to your list of applications in `mix.exs`. This step is only needed if you are using a version older than Elixir 1.4.0 or you already have some applications listed under the `applications` key. In any other case applications are automatically inferred from dependencies (explained in the [Application inference](http://elixir-lang.github.io/blog/2017/01/05/elixir-v1-4-0-released/) section):

```elixir
def application do
  [
    applications: [
      ...,
      :ravenx
    ]
  ]
end
```

## Strategies

From version 2.0, strategies come in separate packages, so the dependencies
needed are not added by default.

To define strategies, just add their packages to your `mix.exs` file and add
them to Ravenx configuration as follows:

```elixir
config :ravenx,
  strategies: [
    email: Ravenx.Strategy.Email
    slack: Ravenx.Strategy.Slack
    my_strategy: MyApp.Ravenx.MyStrategy
  ]
```

We currently maintain two strategies:

* **Slack**: [hex.pm](https://hex.pm/packages/ravenx_slack) | [GitHub](https://github.com/acutario/ravenx_slack)
* **E-mail** (based on Bamboo): [hex.pm](https://hex.pm/packages/ravenx_email) | [GitHub](https://github.com/acutario/ravenx_email)

Also, 3rd party strategies are supported and listed below.

### 3rd party strategies

Amazing people created 3rd party strategies to use Ravenx with more services:

* **Pusher** (thanks to [@behind-design](https://github.com/behind-design)): [hex.pm](https://hex.pm/packages/ravenx_pusher) | [GitHub](https://github.com/behind-design/ravenx-pusher)
* **Telegram** (thanks to [@maratgaliev](https://github.com/maratgaliev)): [hex.pm](https://hex.pm/packages/ravenx_telegram) | [GitHub](https://github.com/maratgaliev/ravenx_telegram)

Anyone can create a strategy that works with Ravenx, so if you have one, please let us know to add it to this list.

### Custom strategies

Maybe there is some internal service you need to call to send notifications, so there is a way to create custom strategies for yout projects.

First of all, you need to create a module that meet the [required behaviour](https://github.com/acutario/ravenx/blob/master/lib/ravenx/strategy_behaviour.ex), like the example you can see [here](https://github.com/acutario/ravenx/blob/master/lib/ravenx/strategy/dummy.ex).

Then you can define custom strategies in application configuration:

```elixir
config :ravenx,
  strategies: [
    my_strategy: YourApp.MyStrategy
  ]
```

and start using your strategy to deliver notifications using the atom assigned (in the example, `my_strategy`).

## Single notification

Sending a single notification is as simply as calling this method:

```elixir
iex> Ravenx.dispatch(strategy, payload)
```

In which `strategy` is an atom indicating one of the defined strategies and the
`payload` is a map with information to dispatch the notification.

For example:

```elixir
iex> Ravenx.dispatch(:slack, %{title: "Hello world!", body: "Science is cool!"})
```

Optionally, a third parameter containing a map of options (like URLs or
secrets) can be passed depending on strategy configuration needs.

## Multiple notifications

You can implement notification modules that `Ravenx` can use to know which strategies should use to send a specific notification.

To do it, you just need to `use Ravenx.Notification` and implement a callback function:

```elixir
defmodule YourApp.Notification.NotifyUser do
  use Ravenx.Notification

  def get_notifications_config(user) do
    # In this function you can define which strategies use for your user (or
    # whatever you want to pass as argument) and return something like:

    [
      slack: {:slack, %{title: "Important notification!", body: "Wait..."}, %{channel: user.slack_username}},
      email_user: {:email, %{subject: "Important notification!", html_body: "<h1>Wait...</h1>", to: user.email_address}},
      email_company: {:email, %{subject: "Important notification about an user!", html_body: "<h1>Wait...</h1>", to: user.company.email_address}},
      other_notification: {:invalid_strategy, %{text: "Important notification!"}, %{option1: value2}},
    ]
  end
end
```

As seen above, strategies can be used multiple times in a notification list (to send multiple e-mails that have different payload, for example).

**Note:** each notification entry in the returned list should include:

1. Atom defining the notification ID.
2. A two or three element tuple containing:
    1. Atom defining which strategy should be used.
    2. Payload map with the data of the notification.
    3. (Optional) Options map for that strategy.

And then you can dispatch your notification using:

```elixir
iex> YourApp.Notification.NotifyUser.dispatch(user)
```

or asynchronously:

```elixir
iex> YourApp.Notification.NotifyUser.dispatch_async(user)
```

Both will return a list with the responses for each notification sent:

```elixir
iex> YourApp.Notification.NotifyUser.dispatch(user)
[
  slack: {:ok, ...},
  email_user: {:ok, ...},
  email_company: {:ok, ...},
  other_notification: {:error, {:unknown_strategy, :invalid_strategy}}
]
```

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
  config :ravenx, :slack,
    url: "...",
    icon: ":bird:"
  ```

### Mixing configurations
Configuration can also be mixed by using the three methods:

 * Static configuration on application configuration.
 * Dynamic configuration common to more than one scenario using a configuration module.
 * Call-specific configuration sending a config Keyword list on `dispatch` method.

## Contribute

All contributions are welcome, and we really hope this repo will serve for beginners as well for more advanced developers.

If you have any doubt, feel free to ask, but always respecting our [Code of Conduct](https://github.com/acutario/ravenx_slack/blob/master/CODE_OF_CONDUCT.md).

To contribute, create a fork of the repository, make your changes and create a PR. And remember, talking on PRs/issues is a must!
