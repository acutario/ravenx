use Mix.Config

config :ravenx,
  strategies: [
    test: Ravenx.Test.TestStrategy,         # Used to test custom strategies and runtime configuration
    test_config: Ravenx.Test.TestStrategy,  # Used to test in-app configuration
    test_module: Ravenx.Test.TestStrategy,  # Used to test module configuration
    test_multiple: Ravenx.Test.TestStrategy # Used to tes configuration from module, in-app and runtime
  ],
  config: Ravenx.Test.TestConfig

config :ravenx, :test_config,
  token: "MySecretToken"

config :ravenx, :test_multiple,
  token: "MySecretToken"
