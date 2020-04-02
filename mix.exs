defmodule FrogAndToad.MixProject do
  use Mix.Project

  def project do
    [
      app: :frog_and_toad,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FrogAndToad.Application, []},
      extra_applications: [:logger, :runtime_tools, :scrabble_ex, :slack]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "deps/slack/test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.16"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:scrabble_ex, path: "/solus/home/zach/labs/scrabble_ex"}, # FIXME
      {:slack, github: "zvkemp/elixir-bot-server", ref: "master"},
      {:credo, "~> 1.0", only: [:dev]},
    ]
  end
end
