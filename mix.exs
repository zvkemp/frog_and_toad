defmodule FrogAndToad.Mixfile do
  use Mix.Project

  def project do
    [app: :frog_and_toad,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {FrogAndToad, []},
     applications: [:phoenix, :cowboy, :logger, :gettext, :slack]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:slack, github: "zvkemp/elixir-bot-server", ref: "d44f9ab50e3648996291bb1bfd0639a55ad2d937"},
     #{:slack, path: "../elixir-bot-server"},
     {:credo, "~> 0.8", only: [:dev]},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false}]
  end
end
