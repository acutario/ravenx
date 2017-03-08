defmodule Ravenx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ravenx,
      version: "1.0.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      docs: docs(),
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {Ravenx, []},
      applications: [
        :logger,
        :poolboy,
        :bamboo,
        :bamboo_smtp,
      ],
      included_applications: [
        :httpoison,
        :poison,
      ]
    ]
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
      {:poison, "~> 2.0 or ~> 3.0"},
      {:poolboy, "~> 1.5"},
      {:httpoison, "~> 0.10.0"},
      {:bamboo, "~> 0.7.0"},
      {:bamboo_smtp, "~> 1.2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.4", only: :dev},
      {:credo, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      source_url: "https://github.com/acutario/ravenx",
      extras: ["README.md"]
    ]
  end

  defp description do
    """
    Notification dispatch library for Elixir applications.
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

  # Always compile files in "lib". In tests compile also files in
  # "test/support"
  def elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  def elixirc_paths(_), do: elixirc_paths()
  def elixirc_paths, do: ["lib"]
end
