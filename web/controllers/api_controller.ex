defmodule FrogAndToad.ApiController do
  use FrogAndToad.Web, :controller

  def index(conn, _params) do
    json(conn, %{})
  end

  def create(conn, %{"bot" => bot, "message" => message, "token" => token}) do
    if token == auth_token() do
      Slack.Bot.say(bot, message)
      json(conn, %{status: "ok"})
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
