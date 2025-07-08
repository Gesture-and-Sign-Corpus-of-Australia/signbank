# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencies
defmodule SignbankWeb.Router do
  use SignbankWeb, :router

  import Oban.Web.Router
  import SignbankWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SignbankWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SignbankWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/terms-and-conditions", PageController, :terms_and_conditions
    get "/about/acknowledgements", PageController, :acknowledgements
    get "/about/classes", PageController, :classes
    get "/about/community", PageController, :community
    get "/research/corpus", PageController, :corpus
    get "/about/history", PageController, :history
    get "/research/annotations", PageController, :annotations
    get "/about/dictionary", PageController, :dictionary
    live "/about/grammar", GrammarLive
    get "/research/vocabulary", PageController, :vocabulary

    live "/dictionary/search", Search, :show
    live "/dictionary/phonological-search", SignLive.PhonologicalSearch, :show

    live "/dictionary/sign/", SignLive.Basic, :search
    live "/dictionary/sign/:id", SignLive.Basic, :show
    live "/dictionary/sign/:id/detail", SignLive.Detail, :show
  end

  # Editor routes
  scope "/", SignbankWeb do
    pipe_through [:browser, :require_authenticated_user, :require_editor_or_tech]

    # TODO: make editor routes
    live_session :editor,
      on_mount: [{SignbankWeb.UserAuth, :require_authenticated}] do
      # live "/dictionary/new", SignLive.Index, :new
      live "/dictionary/sign/:id/edit", SignLive.Edit, :edit
    end
  end

  scope "/tech", SignbankWeb do
    pipe_through [:browser, :require_authenticated_user, :require_tech]

    import Phoenix.LiveDashboard.Router

    live "/", MaintenanceLive

    live_dashboard "/dashboard", metrics: SignbankWeb.Telemetry
    oban_dashboard("/oban")
    # Future tech pages to make:
    # - bulk data loader (maybe just videos)
    # - custom query
    # - export
    # - sign diff
    # - user stats page
  end

  # Other scopes may use custom stacks.
  # scope "/api", SignbankWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:signbank, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SignbankWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SignbankWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", SignbankWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{SignbankWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
