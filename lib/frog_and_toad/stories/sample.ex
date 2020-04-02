defmodule FrogAndToad.Stories.Sample do
  @moduledoc """
  Track staleness for jokes/stories to avoid repeating them too soon after they are told,
  IE a decaying weighted random sample
  """


  # Enum.random
  use GenServer

  def start_link([]) do
    start_link
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  @spec random(:stories | :jokes, binary()) :: atom()
  def random(story_collection, channel) do
    GenServer.call(__MODULE__, {:random, story_collection, channel})
  end

  def by_name(story_collection, channel, name) do
    GenServer.call(__MODULE__, {:by_name, story_collection, channel, name})
  end

  def handle_call({:random, story_type, channel}, _from, state) do
    base_list = apply(FrogAndToad.Stories, story_type, []) |> Enum.zip(Stream.repeatedly(&:rand.normal/0)) |> Enum.into(%{})
    now = timestamp()
    delta_t = state
              |> Map.get(channel, %{})
              |> Enum.filter(fn
                {{^story_type, _}, _} -> true
                _ -> false
              end)
              |> Enum.map(fn {{_, story}, last_heard} ->
                delta_minutes = ((now - last_heard) / 60) + 0.0001
                weight = max(0, (15 / delta_minutes) - 1) + :rand.normal
                {story, weight}
              end)
              |> Enum.into(%{})

    {story, _} = Map.merge(base_list, delta_t) |> Enum.min_by(fn {_, weight} -> weight end)
    key = {story_type, story}
    {:reply, story, Map.update(state, channel, %{key => now}, fn chmap -> Map.put(chmap, key, now) end)}
  end

  def handle_call({:by_name, story_type, channel, name}, _from, state) do
    story = apply(FrogAndToad.Stories, story_type, []) |> Enum.find(&("#{&1}" == name))
    key   = {story_type, story}
    now   = timestamp()
    if story do
      {:reply, story, Map.update(state, channel, %{key => now}, fn chmap -> Map.put(chmap, key, now) end)}
    else
      {:reply, :no_story, state}
    end
  end

  defp timestamp, do: System.monotonic_time(:second)
end
