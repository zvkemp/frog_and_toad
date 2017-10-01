defmodule FrogAndToad.Logger do
  # Simulate slack behavior in the console
  require Logger

  # needs to implement:
  # 1 - pong on pings
  # 2 - blocking behavior
  #

  def connect!(_a, _b) do
    Logger.info("connect: #{[_a, _b] |> inspect}")
    {:fake_socket_for_logger}
  end

  def recv(_a) do
    Process.sleep(3000)
    Logger.info("receive #{self() |> inspect} #{_a |> inspect}")
    { :ok, { :ping, 100 }}
  end

  def send!(_, payload) do
    Logger.info("#{self() |> inspect} sending #{payload |> inspect}")
  end
end
