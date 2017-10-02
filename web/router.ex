defmodule FrogAndToad.Router do
  use FrogAndToad.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FrogAndToad do
    pipe_through :api
  end
end
