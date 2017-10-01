use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :frog_and_toad, FrogAndToad.Endpoint,
  http: [port: (System.get_env("PORT") || "4000") |> String.to_integer],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n", level: :debug

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

config :slack,
  use_console: true,
  default_channel: "channel",
  bots: [
    %{name:    "frogbot",
      token:   "token-1",
      ribbit_msg: "ribbit",
      responder: FrogAndToad.Responder,
      keywords: %{ "cricket" => "WHERE ARE CRICKETS?" },
      socket_client: Slack.Console.Socket,
      api_client: Slack.Console.APIClient,
    },
    %{name:    "toadbot",
      token:   "token-2",
      ribbit_msg: "croak",
      responder: FrogAndToad.Responder,
      keywords: %{ "fly" => "mmm flies", "flies" => "Nothing like a tasty fly! Sure beats crickets." },
      socket_client: Slack.Console.Socket,
      api_client: Slack.Console.APIClient,
    },
    %{name:    "owlbot",
      token:   "token-3",
      ribbit_msg: "whom?",
      responder: FrogAndToad.Responder,
      keywords: %{
        "owl" => "Well owl be damned",
        "hoot" => "hoot hoot"
      },
      socket_client: Slack.Console.Socket,
      api_client: Slack.Console.APIClient
    }
  ]
