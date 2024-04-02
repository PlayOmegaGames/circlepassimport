defmodule QuestApiV21Web.Router do
  use QuestApiV21Web, :router

  import QuestApiV21Web.AccountAuth

  import QuestApiV21Web.SuperadminAuth
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuestApiV21Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
    plug :fetch_current_superadmin
    plug Ueberauth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuestApiV21Web.Layouts, :root}

    plug :protect_from_forgery
    plug :put_secure_browser_headers
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

  #  pipeline :web_auth do
  #    plug :accepts, ["html"]
  #    plug QuestApiV21.WebAuthPipeline
  #  end

  scope "/", QuestApiV21Web do
    pipe_through :browser

    get "/", Web.PageController, :home

    # sign up pages for testing
    get "/sign_in", Web.PageController, :sign_in
    post "/sign_in", AuthController, :html_sign_in
    # post "/sign_up", AuthController, :html_sign_up

    delete "/sign_out", AuthController, :html_sign_out

    live "/sign_up", SignUpLive
    post "/sign_up", AuthController, :sign_up
    post "/set_session", SessionController, :set_session
    live "/test_event", TestLive
  end

  # authentication for API
  scope "/api", QuestApiV21Web do
    pipe_through :api

    # end-user authentication
    get "/sign_up", AuthController, :new
    post "/sign_up", AuthController, :sign_up
    post "/sign_in", AuthController, :sign_in

    # host authentication
    get "/host/sign_up", HostAuthController, :new_host
    post "/host/sign_up", HostAuthController, :sign_up_host
    post "/host/sign_in", HostAuthController, :sign_in_host
    get "/host/:id", HostController, :show

    # token exchange for partner
    post "/token_exchange", AuthController, :token_exchange

    # Bubble retardation
    post "/bubble_wrap", BubbleController, :bubble_wrap
  end

  scope "/api", QuestApiV21Web do
    pipe_through :authenticated_host_api

    resources "/organizations", OrganizationController
    resources "/transactions", TransactionController
    put "/host/change_org", HostController, :change_org
    put "/organization/add_host", OrganizationController, :add_host
    resources "/hosts", HostController, except: [:index]
  end

  # End user authenticated scope fpr api
  scope "/api", QuestApiV21Web do
    pipe_through :authenticated_api
    resources "/quests", QuestController
    resources "/badges", BadgeController
    resources "/collectors", CollectorController
    post "/redeem", RewardController, :redeem
    resources "/accounts", AccountController, except: [:index]
    get "/*path", ErrorController, :not_found
  end

  # |=============================|
  # |         WEB ROUTES          |
  # |=============================|

  scope "/", QuestApiV21Web do
    pipe_through [:browser, :require_authenticated_account]

    live_session :require_authenticated_account,
      on_mount: [
        {QuestApiV21Web.AccountAuth, :ensure_authenticated},
        QuestApiV21Web.Nav
      ],
      layout: {QuestApiV21Web.Layouts, :authenticated} do
      # Live views
      live "/home", MainLive, :home
      live "/home/badges", MainLive, :badges
      live "/home/myquests", MainLive, :myquests
      live "/home/rewards", MainLive, :rewards
      live "/quests", MainLive, :quests
      live "/profile", MainLive, :profile
      live "/badge/:id", CollectorLive
      live "/accounts/settings", Account.AccountSettingsLive, :edit

      live "/accounts/settings/confirm_email/:token",
           Account.AccountSettingsLive,
           :confirm_emailauth_splash

      live "/navbar", QuestApiV21Web.LiveComponents.Navbar, :index, as: :Navbar
      live "/questbar", QuestBarLive
      live "/single_page", SinglePageLive
      delete "/accounts/sign_out", AccountSessionController, :delete
    end
  end

  # for SSO Oauth
  scope "/auth", QuestApiV21Web do
    pipe_through :browser

    get "/:provider", OauthController, :request
    get "/:provider/callback", OauthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuestApiV21Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  # if Application.compile_env(:quest_api_v21, :dev_routes) do
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/dev" do
    pipe_through [:browser, :require_authenticated_superadmin]

    live_dashboard "/dashboard", metrics: QuestApiV21Web.Telemetry
    forward "/mailbox", Plug.Swoosh.MailboxPreview
  end

  # end

  ## Super admin Authentication routes

  scope "/", QuestApiV21Web do
    pipe_through [:browser, :redirect_if_superadmin_is_authenticated]

    live_session :redirect_if_superadmin_is_authenticated,
      on_mount: [{QuestApiV21Web.SuperadminAuth, :redirect_if_superadmin_is_authenticated}] do
      # live "/superadmin/register", Superadmin.SuperadminRegistrationLive, :new
      live "/superadmin/log_in", Superadmin.SuperadminLoginLive, :new
      live "/superadmin/reset_password", Superadmin.SuperadminForgotPasswordLive, :new
      live "/superadmin/reset_password/:token", Superadmin.SuperadminResetPasswordLive, :edit
    end

    post "/superadmin/log_in", SuperadminSessionController, :create
  end

  scope "/", QuestApiV21Web do
    pipe_through [:browser, :require_authenticated_superadmin]

    live_session :require_authenticated_superadmin,
      on_mount: [{QuestApiV21Web.SuperadminAuth, :ensure_authenticated}] do
      live "/superadmin/settings", Superadmin.SuperadminSettingsLive, :edit

      live "/superadmin/settings/confirm_email/:token",
           Superadmin.SuperadminSettingsLive,
           :confirm_email
    end
  end

  scope "/", QuestApiV21Web do
    pipe_through [:browser]

    delete "/superadmin/log_out", SuperadminSessionController, :delete

    live_session :current_superadmin,
      on_mount: [{QuestApiV21Web.SuperadminAuth, :mount_current_superadmin}] do
      live "/superadmin/confirm/:token", Superadmin.SuperadminConfirmationLive, :edit
      live "/superadmin/confirm", Superadmin.SuperadminConfirmationInstructionsLive, :new
    end
  end

  ## End-user account Authentication routes

  scope "/", QuestApiV21Web do
    pipe_through [:browser, :redirect_if_account_is_authenticated]

    live_session :redirect_if_account_is_authenticated,
      on_mount: [{QuestApiV21Web.AccountAuth, :redirect_if_account_is_authenticated}],
      layout: {QuestApiV21Web.Layouts, :registration} do
      live "/accounts/register", Account.AccountRegistrationLive, :new
      live "/accounts/log_in", Account.AccountLoginLive, :new
      live "/accounts/reset_password", Account.AccountForgotPasswordLive, :new
      live "/accounts/reset_password/:token", Account.AccountResetPasswordLive, :edit
    end

    post "/accounts/log_in", AccountSessionController, :create
  end

  scope "/", QuestApiV21Web do
    pipe_through [:browser]

    delete "/accounts/log_out", AccountSessionController, :delete

    live_session :current_account,
      on_mount: [{QuestApiV21Web.AccountAuth, :mount_current_account}] do
      live "/accounts/confirm/:token", AccountConfirmationLive, :edit
      live "/accounts/confirm", AccountConfirmationInstructionsLive, :new
    end
  end
end
