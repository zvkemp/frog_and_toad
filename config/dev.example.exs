use Mix.Config

# copy this to dev.local.exs (which is loaded in development, but ignored by git)
config :slack,
  use_console: true,
  print_to_console: true,
  default_channel: "CHANNEL_ID",
  bots: [
    %{name:    "frogbot",
      token:   "api-token-goes-here",
      ribbit_msg: "ribbit",
      responder: FrogAndToad.Responder,
      keywords: %{ "cricket" => "WHERE ARE CRICKETS?" },
      socket_client: Slack.Console.Socket,
      api_client: Slack.Console.APIClient,
    }
  ]
