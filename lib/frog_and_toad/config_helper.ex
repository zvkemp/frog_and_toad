defmodule FrogAndToad.ConfigHelper do
  # Store production bot configs in a single BOT_CONFIGS env var (for heroku, et al)
  def dump_to_env(bot_conf) do
    bot_conf
    |> :erlang.term_to_binary
    |> Base.encode64
  end

  def load_from_env(str) do
    str
    |> Base.decode64!
    |> :erlang.binary_to_term
  end
end
