defmodule FrogAndToadWeb.ApiController do
  use FrogAndToadWeb, :controller

  def index(conn, _params) do
    json(conn, %{})
  end

  def create(conn, %{"bot" => bot, "workspace" => workspace, "channel" => channel, "message" => message, "token" => token}) do
    if token == auth_token() do
      r = Slack.Bot.say_to_named_channel({workspace, bot}, message, channel)
      json(conn, %{status: r})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "unauthorized"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unacceptable)
    |> json(%{})
  end

  defp auth_token do
    System.get_env("BOT_TOKEN")
  end

end
