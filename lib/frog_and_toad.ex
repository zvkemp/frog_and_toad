defmodule FrogAndToad do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(FrogAndToad.Stories.Sample, [], name: FrogAndToad.Stories.Sample),
      worker(FrogAndToad.ResponseGate, []),
      # Start the endpoint when the application starts
      supervisor(FrogAndToad.Endpoint, []),
      # Here you could define other workers and supervisors as children
      # worker(FrogAndToad.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FrogAndToad.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FrogAndToad.Endpoint.config_change(changed, removed)
    :ok
  end
end
