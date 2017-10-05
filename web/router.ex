defmodule FrogAndToad.Router do
  use FrogAndToad.Web, :router

  pipeline :api do
    plug :accepts, ["json", "html"]
  end

  scope "/", FrogAndToad do
    pipe_through :api
    get "/", ApiController, :index
    post "/say", ApiController, :create
  end
end
