defmodule ShatWeb.Router do
  use ShatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShatWeb do
    pipe_through :browser

    # live "/", ChatLive.Index, :index
    live "/chat/:room_name", ChatLive.Show, :show
    live "/chat/:room_name/set_name", ChatLive.SetName, :set_name

    # Novas rotas
    get "/", ChatController, :index

    get "/chat/:room_name/set", ChatController, :set_user

    get "/chat", ChatController, :enter
    post "/chat", ChatController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShatWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shat, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShatWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
