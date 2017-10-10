defmodule FrogAndToad.ResponseGate do
  use GenServer

  @ttl 120 # seconds

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def go?(key, text, channel, ts, user) do
    GenServer.call(__MODULE__, {:go?, :crypto.hmac(:sha, key, [text, channel, ts, user])})
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

defmodule FrogAndToad.ResponseReminders do
  use GenServer

  @default_reminder_time 300_000 # five minutes

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def remind_user(uid, channel, message, wait_time \\ @default_reminder_time) do
    GenServer.call(__MODULE__, {:schedule_reminder, uid, channel, message, wait_time})
  end

  def cancel_reminder(uid, channel) do
    GenServer.call(__MODULE__, {:cancel_reminder, uid, channel})
  end
end
