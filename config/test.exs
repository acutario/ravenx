use Mix.Config

config :ravenx,
  strategies: [
    test: Ravenx.Test.TestStrategy,         # Used to test custom strategies
    test_config: Ravenx.Test.TestStrategy,  # Used to test in-app configuration
    test_module: Ravenx.Test.TestStrategy   # Used to test module configuration
  ],
  config: Ravenx.Test.TestConfig

config :ravenx, :test_config,
  token: "MySecretToken"
