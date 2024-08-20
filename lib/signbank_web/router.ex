# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencies
defmodule SignbankWeb.Router do
  use SignbankWeb, :router

  import SignbankWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SignbankWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SignbankWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/about/acknowledgements", PageController, :acknowledgements
    get "/about/classes", PageController, :classes
    get "/about/community", PageController, :community
    get "/research/corpus", PageController, :corpus
    get "/about/history", PageController, :history
    get "/research/annotations", PageController, :annotations
    get "/about/dictionary", PageController, :dictionary
    get "/about/grammar", PageController, :grammar
    get "/research/vocabulary", PageController, :vocabulary

    live "/dictionary", SignLive.Index, :index

    live "/dictionary/sign/:id", SignLive.BasicView, :show
    live "/dictionary/sign/:id/linguistic", SignLive.LinguisticView, :show

    # TODO: decide what to do with these
    # These are routes from the "recreated_signbank" project
    # live "/dictionary", SignLive.Index, :index
    # live "/dictionary/edit", SignLive.Edit, :new
    # live "/dictionary/edit/:id_gloss", SignLive.Edit, :edit
    # get "/dictionary/sign/:id_gloss", DictionaryController, :sign
    # get "/dictionary/sign/:id_gloss/detail", DictionaryController, :detail_sign
  end

  # Editor routes
  scope "/", SignbankWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :editor,
      on_mount: [{SignbankWeb.UserAuth, :ensure_authenticated}] do
      live "/dictionary/new", SignLive.Index, :new
      live "/dictionary/sign/:id/edit", SignLive.Edit, :edit
    end
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

  scope "/tech", SignbankWeb do
    pipe_through [:browser, :require_authenticated_tech]

    import Phoenix.LiveDashboard.Router

    live_dashboard "/dashboard", metrics: SignbankWeb.Telemetry
    # Future tech pages to make:
    # - bulk data loader (maybe just videos)
    # - custom query
    # - export
    # - sign diff
    # - user stats page
  end

  ## Authentication routes

  scope "/", SignbankWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SignbankWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SignbankWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SignbankWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", SignbankWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SignbankWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
