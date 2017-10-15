use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :frog_and_toad, FrogAndToad.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :debug

config :slack,
  use_console: true,
  #print_to_console: true,
  story_sleep: 100,
  bots: [
    %{name: "toadbot",
      workspace: "workspace-a",
      socket_client: Slack.Console.Socket,
      api_client: Slack.Console.APIClient,
      token: "toadbot-token",
      ribbit_msg: "croak",
      responder: FrogAndToad.Responder
    },
    %{name: "frogbot",
      workspace: "workspace-a",
      socket_client: Slack.Console.Socket,
      api_client: Slack.Console.APIClient,
      token: "frogbot-token",
      ribbit_msg: "ribbit",
      responder: FrogAndToad.Responder
    },
    %{name: "owlbot",
      workspace: "workspace-a",
      socket_client: Slack.Console.Socket,
      api_client: Slack.Console.APIClient,
      token: "owlbot-token",
      ribbit_msg: "hoot",
      responder: FrogAndToad.Responder
    }
  ]
