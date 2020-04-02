# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :frog_and_toad, FrogAndToad.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "CrXHtbNuOaBv8pgSYtbU+llvEF7wR9ol6NI9GyBPGEkTs02eSb5ZIMS6G/a8DxGX",
  render_errors: [accepts: ~w(json)],
  pubsub: [name: FrogAndToad.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

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
import_config "#{Mix.env}.exs"
