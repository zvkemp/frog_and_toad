defmodule FrogAndToad.ResponderTest do
  use ExUnit.Case, async: false

  # NOTE: There are some timing issues in this test, which seem to be a function of
  # bleeding state (because of the shared global registry?) between tests.
  # It works much better now that the channel name is switched between tests
  #

  def spawn_forwarder do
    pid = self()
    spawn_link fn -> recp(pid) end
  end

  def recp(pid) do
    require Logger
    receive do
      {:push, msg} ->
        send(pid, Poison.decode!(msg))
        recp(pid)
      _ ->
        Process.exit(self(), :normal)
    end
  end

  setup do
    channel_id = :crypto.strong_rand_bytes(9) |> Base.encode64

    # TODO: make this better
    ~w(frogbot toadbot owlbot)
    |> Enum.each(fn name ->
      pid = GenServer.call({:via, Registry, {Slack.BotRegistry, {name, Slack.Bot.Socket}}}, :socket_pid)
      Slack.Console.PubSub.subscribe(channel_id, pid, "user/#{name}")
    end)

    Slack.Console.PubSub.subscribe(channel_id, spawn_forwarder(), "exunit")
    {:ok, %{channel: channel_id}}
  end

  test "bots can respond to other bots", %{channel: c} do
    msg = "hoot hoot hey frogbot"
    Slack.Bot.say("owlbot", msg, c)
    assert_receive(%{"text" => ^msg, "user" => "user/owlbot"}, 200)
    assert_receive(%{"text" => "ribbit", "user" => "user/frogbot"}, 200)
  end

  test "storytime, with a story in progress", %{channel: c} do
    Slack.Console.say({c, "owlbot tell a joke"})
    :timer.sleep(50) # hmmm, this probably means we need a better mutex strategy
    Slack.Console.say({c, "toadbot storytime!"})
    assert_receive(%{"text" => "<@console user> _*SHHHH!*_ We are already telling you a story."}, 500)
  end

  test "storytime, with halting", %{channel: c} do
    Slack.Console.say({c, "owlbot tell a joke"})
    Slack.Console.say({c, "owlbot I am bored"})
    assert_receive(%{"text" => "Drat" <> _bin}, 200)
  end

  test "echoes are echoey", %{channel: c} do
    Slack.Console.say({c, "owlbot tell frogbot to echo toadbot tell owlbot to echo toadbot tell frogbot to echo owlbot echo hey"})

    assert_receive(%{ "user" => "user/owlbot", "text" => "_[whispers to frogbot]_"}, 200)
    assert_receive(%{ "user" => "user/frogbot", "text" => "toadbot tell owlbot to echo toadbot tell frogbot to echo owlbot echo hey"}, 200)
    assert_receive(%{"text" => "_[whispers to owlbot]_", "type" => "message", "user" => "user/toadbot"}, 200)
    assert_receive(%{ "user" => "user/owlbot", "text" => "toadbot tell frogbot to echo owlbot echo hey"}, 200)
    assert_receive(%{ "user" => "user/frogbot", "text" => "owlbot echo hey"}, 200)
    assert_receive(%{ "user" => "user/owlbot", "text" => "hey"}, 200)
  end

  test "echoes are limited-2", %{channel: c} do
    Slack.Console.say({c, "owlbot tell frogbot to echo toadbot echo frogbot echo toadbot tell owlbot to echo toadbot tell frogbot to echo owlbot echo hey"})
    assert_receive(%{"text" => "Drat these echos!", "user" => "user/frogbot"}, 500)
  end
end
