defmodule FrogAndToad.Owlbot do
  import Slack.Bot, only: [say: 3]
  require Logger

  def respond(name, %{ "text" => t, "channel" => c } = msg, %{ id: uid } = config) do
    try do
      cond do
        contains_username?(t, [name, "<@#{uid}>"]) -> parse_command(t, name, msg, config)
        left_the_queue?(t) -> notify_watchers(name, t, c)
        true -> nil
      end
    rescue
      e ->
        say(name, "```\n#{System.stacktrace |> inspect}```", c)
        Logger.error(e |> inspect)
    end
  end

  defp parse_command(t, name, msg, config) do
    sender = Map.get(msg, "user")
    queue = (Regex.run(~r/notify me when (.*) is free/, t) || []) |> Enum.at(1)

    cond do
      queue ->
        set_watcher(name, sender, queue)
        say(name, "Ok <@#{sender}>! I'll let you know when #{queue} is free.", Map.get(msg, "channel"))
      true -> nil
    end
  end

  defp contains_username?(msg, names) do
    Enum.any?(names, &(String.contains?(msg, &1)))
  end

  defp left_the_queue?(msg) do
    String.contains?(msg, "left the queue for") && String.contains?(msg, "Now free")
  end

  defp queue_name(msg) do
    String.split(msg, ~r/left the queue for |\./) |> Enum.at(1)
  end

  defp notify_watchers(name, text, channel) do
    queue = queue_name(text)
    watchers(name, queue) |> Enum.each(fn (w) ->
      say(name, "HOOT <@#{w}> #{queue} is now free. HOOT", channel)
    end)

    GenServer.call(:"#{name}:data", { :update, Map.put(%{}, queue, MapSet.new) })
  end

  defp watchers(name, queue) do
    data = GenServer.call(:"#{name}:data", { :current })
    w = Map.get(data, queue, MapSet.new)
    Logger.info("queue #{queue} watchers #{w |> inspect}")
    w
  end

  defp set_watcher(name, sender, queue) do
    current = watchers(name, queue)
    new_data = Map.put(%{}, queue, MapSet.put(current, sender))
    Logger.info("set_watcher new_data #{new_data |> inspect }")
    GenServer.call(:"#{name}:data", { :update, new_data })
  end
end
