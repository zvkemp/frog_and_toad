defmodule FrogAndToadWeb.Router do
  use FrogAndToadWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/scrabble", as: :scrabble do
    forward "/", ScrabbleExWeb.Router, namespace: "scrabble"
  end

  scope "/", FrogAndToadWeb do
    pipe_through :api

    get "/", ApiController, :index
    post "/say", ApiController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", FrogAndToadWeb do
  #   pipe_through :api
  # end
end
