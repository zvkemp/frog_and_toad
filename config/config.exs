# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :frog_and_toad, FrogAndToadWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ltinHRZyhlVBLCLTEFT06rWxowTUMm5dAPxk9MjY0PE0RDu+oNXB2hdx45+51UjP",
  render_errors: [view: FrogAndToadWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FrogAndToad.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "d44+OC1z"]

config :scrabble_ex, ScrabbleExWeb.Endpoint,
  url: [host: "localhost", path: "/scrabble"],
  secret_key_base: "Cfan9jVmRCwMTUfOygrhMAIlXUUXAwcBRkmUIggYUETiq6Tb1O0hTNqJl3Qe0+hh",
  render_errors: [view: ScrabbleExWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ScrabbleEx.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "Q5UT3WNP"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

defmodule FrogAndToad.ConfigHelper do
  # Store production bot configs in a single BOT_CONFIGS env var (for heroku, et al)
  def dump_to_env(bot_conf) do
    bot_conf
    |> :erlang.term_to_binary
    |> Base.encode64
  end

  def load_from_env(str) do
    str
    |> Base.decode64!
    |> :erlang.binary_to_term
  end
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
