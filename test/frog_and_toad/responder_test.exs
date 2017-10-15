defmodule FrogAndToad.ResponderTest do
  use ExUnit.Case, async: false

  setup do
    channel_id = :crypto.strong_rand_bytes(9) |> Base.encode64
    ws = "workspace-a"

    # TODO: make this better
    ~w(frogbot toadbot owlbot)
    |> Enum.each(fn name ->
      pid = GenServer.call(Slack.BotRegistry.registry_key({ws, name}, Slack.Bot.Socket) , :socket_pid)
      Slack.Console.PubSub.subscribe(ws, channel_id, pid, "user/#{name}")
    end)

    Slack.TestHelpers.subscribe_to_json("workspace-a", channel_id)
    {:ok, %{workspace: ws, channel: channel_id}}
  end

  test "bots can respond to other bots", %{workspace: ws, channel: c} do
    msg = "hoot hoot hey frogbot"
    Slack.Bot.say({ws, "owlbot"}, msg, c)
    assert_receive({:json, %{"text" => ^msg, "user" => "user/owlbot"}}, 200)
    assert_receive({:json, %{"text" => "ribbit", "user" => "user/frogbot"}}, 200)
  end

  test "storytime, with a story in progress", %{workspace: ws, channel: c} do
    Slack.Console.say({ws, c, "owlbot tell a joke"})
    :timer.sleep(50) # hmmm, this probably means we need a better mutex strategy
    Slack.Console.say({ws, c, "toadbot storytime!"})
    assert_receive({:json, %{"text" => "<@console user> _*SHHHH!*_ We are already telling you a story."}}, 500)
  end

  test "storytime, with halting", %{workspace: ws, channel: c} do
    Slack.Console.say({ws, c, "owlbot tell a joke"})
    :timer.sleep(50)
    assert FrogAndToad.Responder.channel_has_story?({ws, c})
    Slack.Console.say({ws, c, "owlbot I am bored"})
    assert_receive({:json, %{"text" => "Drat" <> _bin}}, 200)
    :timer.sleep(50)
    refute FrogAndToad.Responder.channel_has_story?({ws, c})
  end

  test "echoes are echoey", %{workspace: ws, channel: c} do
    Slack.Console.say({ws, c, "owlbot tell frogbot to echo toadbot tell owlbot to echo toadbot tell frogbot to echo owlbot echo hey"})

    assert_receive({:json, %{"user" => "user/owlbot", "text" => "_[whispers to frogbot]_"}}, 200)
    assert_receive({:json, %{"user" => "user/frogbot", "text" => "toadbot tell owlbot to echo toadbot tell frogbot to echo owlbot echo hey"}}, 200)
    assert_receive({:json, %{"text" => "_[whispers to owlbot]_", "type" => "message", "user" => "user/toadbot"}}, 200)
    assert_receive({:json, %{"user" => "user/owlbot", "text" => "toadbot tell frogbot to echo owlbot echo hey"}}, 200)
    assert_receive({:json, %{"user" => "user/frogbot", "text" => "owlbot echo hey"}}, 200)
    assert_receive({:json, %{"user" => "user/owlbot", "text" => "hey"}}, 200)
  end

  test "echoes are limited-2", %{workspace: ws, channel: c} do
    Slack.Console.say({ws, c, "owlbot tell frogbot to echo toadbot echo frogbot echo toadbot tell owlbot to echo toadbot tell frogbot to echo owlbot echo hey"})
    assert_receive({:json, %{"text" => "Drat these echos!", "user" => "user/frogbot"}}, 500)
  end
end
