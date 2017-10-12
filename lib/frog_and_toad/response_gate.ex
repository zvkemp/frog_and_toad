defmodule FrogAndToad.ResponseGate do
  use GenServer

  @ttl 120 # seconds

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def go?(key, text, {ws, channel}, ts, user) do
    GenServer.call(__MODULE__, {:go?, :crypto.hmac(:sha, key, [text, ws, channel, ts, user])})
  end

  def handle_call({:go?, key}, _from, state) do
    answer = !Map.has_key?(state, key)
    ts = System.monotonic_time(:seconds)
    new_state = state
                |> Enum.filter(fn {_, v} -> v + @ttl < ts end)
                |> Enum.into(%{})
                |> Map.put_new(key, ts)
    {:reply, answer, new_state}
  end
end
