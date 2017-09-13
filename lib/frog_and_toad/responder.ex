defmodule FrogAndToad.Responder do
  import Slack.Bot, only: [say: 3]
  require Logger
  def respond(name, %{ "text" => t, "channel" => c } = msg, %{ id: uid, ribbit_msg: r, keywords: k } = config) do
    try do
      cond do
        contains_username?(t, [name, "<@#{uid}>"]) ->
          parse_command(t, name, msg, config)
          || say(name, r, c)
        contains_keyword?(t, k) ->
          try_keyword_response(name, msg, config)
        true -> nil
      end
      # end
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

  defp parse_command(t, name, msg, %{ id: uid } = config) do
    mention = "<@#{uid}>"
    cond do
      String.starts_with?(t, name)    -> parse_command(String.split(t, name, parts: 2)    |> Enum.at(1) |> String.strip, name, msg, config, { name })
      String.starts_with?(t, mention) -> parse_command(String.split(t, mention, parts: 2) |> Enum.at(1) |> String.strip, name, msg, config, { name })
      true                            -> nil
    end
  end

  defp parse_command("error" <> t, _, %{ "channel" => c, "user" => user }, %{ id: uid } = config, { bot }) do
    raise t
  end

  defp parse_command("I am bored" <> t, _, %{ "channel" => c, "user" => user }, %{ id: uid } = config, { bot }) do
    pid = Process.whereis(:storytime)
    cond do
      pid ->
        Process.exit(pid, :shutdown)
        say(bot, "Drat this ungrateful audience. Come back later for a different story!", c)
      # TODO: put in actual bot names here
      true -> say(bot, "Why don't you try talking to #{Enum.shuffle(["gashley", "bobabot", "doobot"]) |> List.first} for a while", c)
    end
  end

  defp parse_command("storytime!" <> t, _, %{ "channel" => c, "user" => user }, %{ id: uid } = config, { bot }) do
    cond do
      Process.whereis(:storytime) -> say(bot, "<@#{user}> _*SHHHH!*_ We are already telling you a story.", c)
      true ->
        { :ok, pid } = Task.start(fn ->
          FrogAndToad.Stories.story |> Enum.each(fn (line) -> storyline(line, c) end)
        end)
        Process.register(pid, :storytime)
    end
  end

  defp parse_command("tell a joke" <> t, _, %{ "channel" => c, "user" => user }, %{ id: uid } = config, { "owlbot" = bot}) do
    cond do
      Process.whereis(:storytime) -> say(bot, "<@#{user}> _*SHHHH!*_ We are already telling you a story.", c)
      true ->
        { :ok, pid } = Task.start(fn ->
          FrogAndToad.Stories.owl_joke |> Enum.each(fn (line) -> storyline(line, c) end)
        end)
        Process.register(pid, :storytime)
    end
  end

  defp storyline([bot, str, sleep], channel) do
    say("#{bot}", str, channel)
    :timer.sleep(sleep)
  end

  defp storyline([bot, str], ch) do
    storyline([bot, str, 2000], ch)
  end

  defp parse_command("echo " <> t, _, %{ "channel" => c }, %{ id: uid } = config, { bot }) do
    cond do
      Regex.scan(~r/echo/, t) |> Enum.count > 3 ->
        say(bot, "Drat these echos!", c)
      true -> say(bot, t, c)
    end
  end

  def narrate(str) do
    "_[#{str}]_"
  end

  defp parse_command("tell " <> t, name, %{ "channel" => c } = msg, %{ id: uid } = config, { bot }) do
    case String.split(t, ~r/\s/, parts: 3) do
      [other_bot, "to", command] ->
        cond do
          Process.whereis(:"#{other_bot}:supervisor") ->
            say(bot, narrate("whispers to #{other_bot}"), c)
            parse_command("#{other_bot} #{command}", other_bot, msg, config)
          true ->
            say(bot, "No! I am afraid of talking to #{other_bot}.", c)
        end
      _ -> nil
    end
  end

  defp parse_command(_, _, _, _, _), do: nil

  defp try_command("echo" = cmd, name, %{ "text" => t, "user" => user, "channel" => c }, %{ id: uid, ribbit_msg: r }) do
    mention = "<@#{uid}>"
    cond do
      String.starts_with?(t, "#{name} #{cmd} ") || String.starts_with?(t, "#{mention} #{cmd} ") ->
        say(name, String.split(t, " #{cmd} ", parts: 2) |> Enum.at(1), c)
      true -> nil
    end
  end

  defp try_command(_, _, _, _), do: nil

  defp contains_username?(msg, names) do
    Enum.any?(names, &(String.contains?(msg, &1)))
  end

  defp contains_keyword?(t, keywords) do
    dn = String.downcase(t)
    Enum.any?(keywords, fn ({ word, _ }) -> String.contains?(dn, word) end)
  end

  defp try_keyword_response(name, %{ "text" => t, "user" => user, "channel" => c }, %{ keywords: k }) do
    dn = String.downcase(t)
    { _, resp } = Enum.find(k, fn ({ word, _ }) -> String.contains?(dn, word) end)
    say(name, resp, c)
  end
end
