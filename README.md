# Ravenx

Notification dispatch library for Elixir applications (WIP).

## Usage

Usage is as simply as calling this method:

```elixir
iex> Ravenx.dispatch(strategy, payload)
```

In which `stratey` is an atom indicating one of the defined strategies and the
`payload` is a Keyword list with information to dispatch the notification.

For example:

```elixir
iex> Ravenx.dispatch(:slack, [title: "Hello world!", body: "Science is cool!"])
```

Optionally, a third parameter containing a Keyword list of options (like URLs or
secrets) can be passed.

## Configuration
Strategies usually needs configuration options. To solve that, there are three 
ways in which you can configure a notification dispatch strategy:

1. Passing the options in the dispatch call:

```elixir
iex> Ravenx.dispatch(:slack, [title: "Hello world!", body: "Science is cool!"], [url: "...", icon: ":bird:"])
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
    [
      url: "...",
      icon: ":bird:"
    ]
  end
end
```

**Note:** the module should contain a function called as the strategy yopu are 
configuring, receiving the payload and returning a configuration Keyword list.

3. Specifying the configuration directly on your application config file:

```elixir
config :ravenx,
  slack: [
    url: "...",
    icon: ":bird:"
  ]
```

### Mixing configurations
Configuration can also be mixed by using the three methods:

 * Static configuration on application configuration.
 * Dynamic configuration common to more than one scenario using a configuration module.
 * Call-specific configuration sending a config Keyword list on `dispatch` method.