defmodule Ravenx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ravenx,
      version: "0.0.1-alpha",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 3.0"},
      {:httpotion, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.4", only: :dev}
    ]
  end

  defp description do
    """
    Notification dispatch library for Elixir applications (WIP).
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :ravenx,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Óscar de Arriba"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/acutario/ravenx"}
    ]
  end
end
