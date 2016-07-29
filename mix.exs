defmodule ExtaticDatadog.Mixfile do
  use Mix.Project

  def project do
    [app: :extatic_datadog,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:httpoison, :logger]]
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
    {:httpoison, "~> 0.9.0"},
     {:poison, "~> 2.0"},
     {:extatic, "0.1.0"}]
  end

  defp description do
    """
    A DataDog plugin for Extatic to log events and metrics to DataDog
    """
  end

  defp package do
     [
       name: :extatic_datadog,
       files: ["lib", "mix.exs", "README*", "LICENSE*"],
       maintainers: ["Anthony Graham"],
       licenses: ["Apache 2.0"],
       links: %{"GitHub" => "https://github.com/trinode/extatic_datadog"}
     ]
  end
end
