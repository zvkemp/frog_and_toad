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
          [
            [:toadbot, narrate("wakes up")],
            [:toadbot, "Drat!"],
            [:toadbot, "This house is a mess. I have so much work to do."],
            [:frogbot, narrate "looks through the window"],
            [:frogbot, "toadbot, you are right."],
            [:frogbot, "It is a mess."],
            [:toadbot, narrate "pulls the covers over his head"],
            [:toadbot, "I will do it tomorrow."],
            [:toadbot, "Today I will take life easy."],
            [:frogbot, narrate "comes into the house"],
            [:frogbot, "toadbot, your pants and jacket are lying on the floor."],
            [:toadbot, "_(from under the covers)_ Tomorrow."],
            [:frogbot, "Your kitchen sink is filled with dirty dishes."],
            [:toadbot, "Tomorrow."],
            [:frogbot, "There is dust on your chairs."],
            [:toadbot, "Tomorrow."],
            [:frogbot, "Your windows need scrubbing."],
            [:frogbot, "Your plants need watering."],
            [:toadbot, "_*Tomorrow!*_"],
            [:toadbot, "_*I will do it all tomorrow!*_"],
            [:toadbot, narrate "sits on the edge of his bed"],
            [:toadbot, "Blah." ],
            [:toadbot, "I feel down in the dumps."],
            [:frogbot, "Why?"],
            [:toadbot, "I am thinking about tomorrow." ],
            [:toadbot, "I am thinking about all of the many things that I will have to do."],
            [:frogbot, "Yes, tomorrow will be a very hard day for you."],
            [:toadbot, "But frogbot, if I pick up my pants and jacket right now, then I will not have to pick them up tomorrow, will I?"],
            [:frogbot, "No. You will not have to."],
            [:toadbot, narrate "picks up his clothes"],
            [:toadbot, narrate "puts them in the closet"],
            [:toadbot, "frogbot, if I wash my dishes right now then I will not have to wash them tomorrow, will I?"],
            [:frogbot, "No. You will not have to."],
            [:toadbot, narrate "washes and dries his dishes."],
            [:toadbot, narrate "puts them in the cupboard"],
            [:toadbot, "frogbot, if I dust my chairs and scrub my windows and water my plants right now, then I will not have to do it tomorrow, will I?"],
            [:frogbot, "No, you will not have to do any of it."],
            [:toadbot, narrate "dusts his chairs"],
            [:toadbot, narrate "scrubs his windows"],
            [:toadbot, narrate "waters his plants"],
            [:toadbot, "There. Now I feel better."],
            [:toadbot, "I am not in the dumps anymore."],
            [:frogbot, "Why?"],
            [:toadbot, "Because I have done all that work." ],
            [:toadbot, "Now I can save tomorrow for something that I really want to do."],
            [:frogbot, "What is that?"],
            [:toadbot, "Tomorrow, I can just take life easy."],
            [:toadbot, narrate "goes back to bed"],
            [:toadbot, narrate "pulls the covers over his head and falls asleep"]
          ] |> Enum.each(fn (line) -> storyline(line, c) end)
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

  defp narrate(str) do
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
