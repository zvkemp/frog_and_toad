defmodule FrogAndToad.Responder do
  import Slack.Bot, only: [say: 3]
  def respond(name, %{ "text" => t, "channel" => c } = msg, %{ id: uid, ribbit_msg: r, keywords: k } = config) do
    cond do
      contains_username?(t, [name, "<@#{uid}>"]) ->
        parse_command(t, name, msg, config) |> IO.inspect
        || say(name, r, c)
      contains_keyword?(t, k) ->
        try_keyword_response(name, msg, config)
      true -> nil
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

  defp parse_command("echo " <> t, _, %{ "channel" => c }, %{ id: uid } = config, { bot }) do
    cond do
      Regex.scan(~r/echo/, t) |> Enum.count > 3 ->
        say(bot, "Drat these echos!", c)
      true -> say(bot, t, c)
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
