defmodule FrogAndToad.Responder do
  import Slack.Bot, only: [say: 3]
  alias Slack.Bot.Config, as: C

  require Logger
  def respond(name, %{"text" => t, "channel" => c} = msg, %C{id: uid, keywords: k} = config) do
    try do
      cond do
        String.contains?(t, [name, "<@#{uid}>"]) ->
          handle_mention(t, name, msg, config)
        contains_keyword?(t, k) ->
          try_keyword_response(name, msg, config)
        true -> nil
      end
    rescue
      e ->
        say(name, "_I do not feel well._ `#{e |> inspect}`", c)
        say(name, "```\n#{System.stacktrace |> inspect}```", c)
        Logger.error(e |> inspect)
    end
  end

  def respond(_, _, _) do
    nil
  end

  # Detect if the string starts with the bot's name or @-mention
  defp handle_mention(text, name, msg, %{id: uid} = config) do
    mentions = ["<@#{uid}>", name]
    if String.starts_with?(text, mentions) do
      parse_command(
        text
        |> String.split(mentions, parts: 2)
        |> Enum.at(1)
        |> String.trim, name, msg, config, {name}
      )
    else
      say(name, config.ribbit_msg, msg["channel"])
    end
  end

  defp parse_command("error" <> t, _, _msg, _config, {_bot}) do
    raise t
  end

  # start a story sequence
  defp parse_command("storytime!" <> _t, _, %{"channel" => c, "user" => user}, _config, {bot}) do
    storytime(c, :story, bot, user)
  end

  # start a joke sequence
  defp parse_command("tell a joke" <> _t, _, %{"channel" => c, "user" => user}, _config, {"owlbot" = bot}) do
    storytime(c, :joke, bot, user)
  end

  # stop a running story
  defp parse_command("I am bored" <> _t, _, %{"channel" => c}, _config, {bot}) do
    if pid = channel_has_story?(c) do
      Process.exit(pid, :shutdown)
      say(bot, "Drat this ungrateful audience. Come back later for a different story!", c)
    else
      say(bot, "Why don't you try talking to someone else for a while", c)
    end
  end

  defp parse_command("echo " <> t, _, %{"channel" => c}, %{id: uid} = config, {bot}) do
    if ~r/echo/ |> Regex.scan(t) |> Enum.count > 3 do
      say(bot, "Drat these echos!", c)
    else
      say(bot, t, c)
    end
  end

  # forward a command to another bot
  defp parse_command("tell " <> t, _name, %{ "channel" => c } = msg, config, {bot}) do
    case String.split(t, ~r/\s/, parts: 3) do
      [other_bot, "to", command] ->
        if Slack.BotRegistry.lookup({other_bot, Slack.Bot.Supervisor}) do
          say(bot, narrate("whispers to #{other_bot}"), c)
          handle_mention("#{other_bot} #{command}", other_bot, msg, config)
        else
          say(bot, "No! I am afraid of talking to #{other_bot}.", c)
        end
      _ -> nil
    end
  end

  # default, user was mentioned but no command matched.
  defp parse_command(_t, _, %{"channel" => c}, config, {bot}) do
    say(bot, config.ribbit_msg, c)
  end

  @spec storytime(binary, :joke | :story, binary, binary) :: :ok
  defp storytime(channel, story_type, bot, user) do
    case start_monitored_story(channel, story_type) do
      {:ok, _} -> :ok
      {:error, :already_started} -> say(bot, "<@#{user}> _*SHHHH!*_ We are already telling you a story.", channel)
    end
  end

  @spec start_monitored_story(binary, :joke | :story) :: {:ok, pid} | {:error, :already_started} | {:error}
  defp start_monitored_story(channel, story_type) do
    if channel_has_story?(channel) do
      {:error, :already_started}
    else
      {:ok, pid} = Task.start(fn ->
        FrogAndToad.Stories
        |> apply(story_type, [channel])
        |> Enum.each(fn (line) -> storyline(line, channel) end)
      end)

      Registry.register(Slack.BotRegistry, {:storytime, channel}, pid)

      spawn fn ->
        Process.monitor(pid)
        receive do
          {:DOWN, _, _, ^pid} -> Registry.unregister(Slack.BotRegistry, {:storytime, channel})
        end
      end

      {:ok, pid}
    end
  end

  defp channel_has_story?(channel) do
    case Slack.BotRegistry.lookup({:storytime, channel}) do
      {_, pid} -> pid
      _ -> false
    end
  end

  defp storyline([bot, str, sleep], channel) do
    say("#{bot}", str, channel)
    :timer.sleep(sleep)
  end

  defp storyline([bot, str], ch) do
    storyline([bot, str, default_storyline_sleep()], ch)
  end

  defp default_storyline_sleep, do: Application.get_env(:slack, :story_sleep, 2_000)

  def narrate(str) do
    "_[#{str}]_"
  end


  defp try_command("echo" = cmd, name, %{"text" => t, "user" => user, "channel" => c}, %{id: uid, ribbit_msg: r}) do
    mention = "<@#{uid}>"
    if String.starts_with?(t, "#{name} #{cmd} ") || String.starts_with?(t, "#{mention} #{cmd} "), do:
    name |> say(t |> String.split(" #{cmd} ", parts: 2) |> Enum.at(1), c)
  end

  defp try_command(_, _, _, _), do: nil

  defp contains_keyword?(t, keywords) do
    dn = String.downcase(t)
    String.contains?(dn, keywords |> Map.keys)
  end

  defp try_keyword_response(name, %{"text" => t, "user" => _user, "channel" => c}, %{keywords: k}) do
    dn = String.downcase(t)
    {_, resp} = Enum.find(k, fn ({word, _}) -> String.contains?(dn, word) end)
    say(name, resp, c)
  end
end
