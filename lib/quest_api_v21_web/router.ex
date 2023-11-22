defmodule QuestApiV21Web.Router do
  use QuestApiV21Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuestApiV21Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug :accepts, ["html"]
    plug QuestApiV21Web.AuthPlug
  end

  pipeline :authenticated_api do
    plug :accepts, ["json"]
    plug QuestApiV21.GuardianPipeline
  end

  pipeline :authenticated_host_api do
    plug :accepts, ["json"]
    plug QuestApiV21.HostGuardianPipeline

  end

  scope "/", QuestApiV21Web do
    pipe_through :browser

    get "/", PageController, :home


    #sign up pages for testing
    get "/sign_in", PageController, :sign_in
    get "/sign_up", PageController, :sign_up
    post "/sign_in", AuthController, :html_sign_in
    post "/sign_up", AuthController, :html_sign_up

  end

  scope "/", QuestApiV21Web do
    pipe_through [:browser, :authenticated]  # Use both browser and authenticated pipelines

    #badge page
    get "/badge/:id", CollectorController, :show_collector
    get "/badges", BadgeController, :show_badge

  end

  scope "/api", QuestApiV21Web do
    pipe_through :authenticated_host_api

    resources "/organizations", OrganizationController
    resources "/scans", ScanController
    resources "/hosts", HostController, except: [:index]
  end


  scope "/api", QuestApiV21Web do
    pipe_through :api

    #account authentication
    get "/sign_up", AuthController, :new
    post "/sign_up", AuthController, :sign_up
    post "/sign_in", AuthController, :sign_in

    #host authentication
    get "/host/sign_up", HostAuthController, :new_host
    post "/host/sign_up", HostAuthController, :sign_up_host
    post "/host/sign_in", HostAuthController, :sign_in_host

    #token exchange for partner
    post "/token_exchange", AuthController, :token_exchange

  end

  scope "/api", QuestApiV21Web do
    pipe_through :authenticated_api
    resources "/quests", QuestController
    resources "/badges", BadgeController
    resources "/collectors", CollectorController
    resources "/accounts", AccountController, except: [:index]
    get "/*path", ErrorController, :not_found

  end


  # Other scopes may use custom stacks.
  # scope "/api", QuestApiV21Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:quest_api_v21, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QuestApiV21Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
