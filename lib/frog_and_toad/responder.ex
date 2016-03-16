defmodule FrogAndToad.Responder do
  import Slack.Bot, only: [say: 3]
  def respond(name, %{ "text" => t, "channel" => c } = msg, %{ id: uid, ribbit_msg: r, keywords: k } = config) do
    cond do
      contains_username?(t, [name, "<@#{uid}>"]) ->
        try_command("echo", name, msg, config)
        || say(name, r, c)
      contains_keyword?(t, k) ->
        try_keyword_response(name, msg, config)
      true -> nil
    end
  end

  def respond(_, _, _) do
    nil
  end


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
