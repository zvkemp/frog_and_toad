defmodule FrogAndToad.Responder do
  import Slack.Bot, only: [say: 3]
  alias Slack.Bot
  alias Slack.Bot.Config, as: C

  require Logger

  @spec respond(Bot.bot_name, map, C.t) :: any
  def respond({_, uname} = bot, %{"text" => t, "channel" => c} = msg, %C{id: uid, keywords: k} = config) do
    try do
      cond do
        String.contains?(t, [uname, "<@#{uid}>"]) ->
          handle_mention(t, bot, msg, config)
        contains_keyword?(t, k) ->
          try_keyword_response(bot, msg, config)
        someone_telling_a_joke?(t) ->
          wait_for_joke_response(bot, msg, config)
        someone_finishing_a_joke?(t) ->
          Logger.debug("finishing joke")
          cancel_pending_reminders(bot, msg, config)
        true -> nil
      end
    rescue
      e ->
        say(bot, "_I do not feel well._ `#{e |> inspect}`", c)
        Logger.error(e |> inspect)
    end
  end

  def respond(_, _, _) do
    nil
  end

  defp someone_telling_a_joke?("Q:" <> _), do: true
  defp someone_telling_a_joke?(_), do: false

  # TODO: finish implementing this. Need to tie back to original username, and the timer process
  # should be canceled when this comes in. Could probably do this all through the ResponseGate, using timer refs!
  # woot
  #
  # - handle telling a new joke when the old one isn't finished (send reminder immediately)
  defp someone_finishing_a_joke?("A:" <> _), do: true
  defp someone_finishing_a_joke?(_), do: false

  defp wait_for_joke_response({ws, _} = bot, %{"text" => t, "channel" => c, "user" => u, "ts" => ts}, _config) do
    if FrogAndToad.ResponseGate.go?("response_gate", t, {ws, c}, ts, u) do
      rkey = reminder_key(u, ws, c)

      if !Process.whereis(rkey) do
        "Q:" <> q = t

        {:ok, pid} = Task.start fn ->
          :timer.sleep(60_000)
          say(bot, "...", c)
          :timer.sleep(60_000 * 5)
          say(bot, "...", c)
          :timer.sleep(60_000 * 2)
          say(bot, "<@#{u}> We're still waiting for an answer! #{q}", c)
        end

        Process.register(pid, rkey)
      end
    end
  end

  defp reminder_key(user, workspace, channel) do
    :"reminder:#{workspace}:#{user}:#{channel}"
  end

  defp cancel_pending_reminders({ws, _} = bot, %{"text" => t, "channel" => c, "user" => u, "ts" => ts}, _config) do
    if FrogAndToad.ResponseGate.go?("cancel_pending", t, {ws, c}, ts, u) do
      Logger.debug({:cancel_pending_reminders, t, ws, c, ts, u} |> inspect)
      if pid = Process.whereis(reminder_key(u, ws, c)), do: Process.exit(pid, :shutdown)
      response = Enum.random([
        "HAHAHAHA! Good one",
        "lol",
        "HA!",
        "LOL",
        "hah",
        "_[chuckles quietly]_",
        "BWA-HAHAHAHAHA!",
        "_[groans]_",
        "_[nods along]_",
        "hmph",
        "Don't quit your day job, I guess",
        "Inconceivable!",
        "That's hilarious",
        "oh no",
        "I'm stealing that",
        "nice",
        "haha",
        "_[leaves channel]_"
      ])
      say(bot, response, c)
    end
  end

  defp cancel_pending_reminders(b, msg, config) do
    Logger.warn({b, msg, config} |> inspect)
  end

  # Detect if the string starts with the bot's name or @-mention
  defp handle_mention(text, {_ws, name} = bot, msg, %{id: uid} = config) do
    mentions = ["<@#{uid}>", name]
    if String.starts_with?(text, mentions) do
      parse_command(
        text
        |> String.split(mentions, parts: 2)
        |> Enum.at(1)
        |> String.trim, bot, msg, config
      )
    else
      if :rand.uniform > 0.3, do:
        say(bot, config.ribbit_msg, msg["channel"])
    end
  end

  defp parse_command("error" <> t, _, _msg, _config) do
    raise t
  end

  defp parse_command("help" <> _t, bot, %{"channel" => c, "user" => user}, _config) do
    storytime(c, :help, bot, user)
  end

  defp parse_command("what else do you know" <> _t, {ws, _} = bot, %{"channel" => c, "user" => user}, _config) do
    if pid = channel_has_story?({ws, c}) do
      Process.exit(pid, :shutdown)
    end

    say(bot,
        FrogAndToad.Stories.stories
        |> Enum.map(&"frogbot storytime #{&1}")
        |> Enum.join("\n"),
        c)
  end

  # start a story sequence
  defp parse_command("storytime!" <> _t, bot, %{"channel" => c, "user" => user}, _config) do
    storytime(c, :story, bot, user)
  end

  defp parse_command("storytime: " <> story_name, bot, %{"channel" => c, "user" => user}, _config) do
    storytime(c, {:story, story_name}, bot, user)
  end

  defp parse_command("storytime " <> story_name, bot, %{"channel" => c, "user" => user}, _config) do
    storytime(c, {:story, story_name}, bot, user)
  end

  # start a joke sequence
  defp parse_command("tell a joke" <> _t, {_, "owlbot"} = bot, %{"channel" => c, "user" => user}, _config) do
    storytime(c, :joke, bot, user)
  end

  # start a joke sequence
  defp parse_command("tell a joke" <> _t, bot, %{"channel" => c}, _config) do
    say(bot, "No. But if you're looking for a hoot...", c)
    say(bot, "owlbot tell a joke", c)
  end

  # stop a running story
  defp parse_command("I am bored" <> _t, {ws, _} = bot, %{"channel" => c}, _config) do
    if pid = channel_has_story?({ws, c}) do
      Process.exit(pid, :shutdown)
      say(bot, "Drat this ungrateful audience. Come back later for a different story!", c)
    else
      say(bot, "Why don't you try talking to someone else for a while", c)
    end
  end

  defp parse_command("echo " <> t, bot, %{"channel" => c}, _config) do
    if ~r/echo/ |> Regex.scan(t) |> Enum.count > 3 do
      say(bot, "Drat these echos!", c)
    else
      say(bot, t, c)
    end
  end

  defp parse_command("mention me in a minute" <> _, bot, %{"user" => u, "channel" => c}, _config) do
    say(bot, "sure thing boss", c)
    Task.start(fn ->
      :timer.sleep(10_000)
      say(bot, "<@#{u}> has it been a minute yet?", c)
    end)
  end

  # forward a command to another bot
  defp parse_command("tell " <> t, {ws, _} = bot, %{"channel" => c} = msg, config) do
    case String.split(t, ~r/\s/, parts: 3) do
      [other_bot, "to", command] ->
        if Slack.BotRegistry.lookup({{ws, other_bot}, Slack.Bot.Supervisor}) do
          say(bot, narrate("whispers to #{other_bot}"), c)
          handle_mention("#{other_bot} #{command}", {ws, other_bot}, msg, config)
        else
          say(bot, "No! I am afraid of talking to #{other_bot}.", c)
        end
      _ -> nil
    end
  end

  # default, user was mentioned but no command matched.
  defp parse_command(_t, bot, %{"channel" => c}, config) do
    if :rand.uniform > 0.3, do:
      say(bot, config.ribbit_msg, c)
  end

  @spec storytime(String.t, (:joke | :story | :help) | {atom, String.t}, Bot.bot_name, String.t) :: :ok
  defp storytime(channel, story_type, {workspace, _} = bot, user) do
    case start_monitored_story(workspace, channel, story_type) do
      {:ok, _} -> :ok
      {:error, :already_started} -> say(bot, "<@#{user}> _*SHHHH!*_ We are already telling you a story.", channel)
    end
  end

  @spec start_monitored_story(String.t, String.t, :joke | :story) :: {:ok, pid} | {:error, :already_started} | {:error}
  defp start_monitored_story(workspace, channel, story_type) do
    ch_ref = {workspace, channel}

    {story_type, args} = case story_type do
      {type, name} -> {type, [ch_ref, name]}
      type -> {type, [ch_ref]}
    end

    if channel_has_story?(ch_ref) do
      {:error, :already_started}
    else
      {:ok, pid} = Task.start(fn ->
        FrogAndToad.Stories
        |> apply(story_type, args)
        |> Enum.each(fn (line) -> storyline(line, workspace, channel) end)
      end)

      spawn fn ->
        # NOTE: Registry.register/unregister must be called from the same process
        Registry.register(Slack.BotRegistry, {:storytime, ch_ref}, pid)
        ref = Process.monitor(pid)
        receive do
          {:DOWN, ^ref, _, _, _} -> Registry.unregister(Slack.BotRegistry, {:storytime, ch_ref})
          msg -> Logger.warn({"unhandled in monitor", msg} |> inspect)
        end
      end

      {:ok, pid}
    end
  end

  def channel_has_story?({_, _} = channel) do
    case Slack.BotRegistry.lookup({:storytime, channel}) do
      {_, pid} -> if Process.alive?(pid), do: pid
      _ -> false
    end
  end

  defp storyline([name, str, sleep], workspace, channel) do
    say({workspace, "#{name}"}, str, channel)
    :timer.sleep(sleep)
  end

  defp storyline([bot, str], ws, ch) do
    storyline([bot, str, default_storyline_sleep()], ws, ch)
  end

  defp default_storyline_sleep, do: Application.get_env(:slack, :story_sleep, 2_000)

  def narrate(str) do
    "_[#{str}]_"
  end


  defp try_command("echo" = cmd, {_ws, name} = bot, %{"text" => t, "user" => user, "channel" => c}, %{id: uid, ribbit_msg: r}) do
    mention = "<@#{uid}>"
    if String.starts_with?(t, "#{name} #{cmd} ") || String.starts_with?(t, "#{mention} #{cmd} "), do:
    bot |> say(t |> String.split(" #{cmd} ", parts: 2) |> Enum.at(1), c)
  end

  defp try_command(_, _, _, _), do: nil

  defp contains_keyword?(t, keywords) do
    dn = String.downcase(t)
    String.contains?(dn, keywords |> Map.keys)
  end

  defp try_keyword_response(bot, %{"text" => t, "user" => _user, "channel" => c}, %{keywords: k}) do
    dn = String.downcase(t)
    {_, resp} = Enum.find(k, fn ({word, _}) -> String.contains?(dn, word) end)
    say(bot, resp, c)
  end
end
