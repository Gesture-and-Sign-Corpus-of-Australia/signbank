defmodule SignbankWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use SignbankWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar text-yellow bg-purple p-0 m-0 pr-2">
      <div data-class="navbar-start" class="align-stretch flex-1 flex items-center gap-2 min-h-[84px]">
        <a href="/" aria-label="Homepage" id="logo" class="mb-1 mt-[max(-2%,-22px)] max-w-[35vw]">
          <img
            alt="The Auslan Signbank logo. Yellow and light yellow text saying 'Auslan Signbank'."
            src={~p"/images/logo.svg"}
          />
        </a>

        <button
          type="button"
          href="#"
          class="md:hidden btn btn-square btn-ghost drawer-button ms-auto select-none hover:bg-slate-600"
          aria-expanded="false"
          data-target="navbarBasicExample"
          phx-click={
            JS.toggle_class("hidden", to: "#menu-sm")
            |> JS.toggle_class("is-active", to: ".navbar-burger")
          }
        >
          <.icon name="hero-bars-3" class="bg-yellow size-8" />
        </button>
      </div>

      <%!-- TODO: add search bar (and yknow all the other menu items) --%>
      <.nav />
    </header>

    <.nav id="menu-sm" mobile />

    <%!-- <main class="px-4 py-20 sm:px-6 lg:px-8"> --%>
    <main class="mx-auto max-w-4xl space-y-4">
      {render_slot(@inner_block)}
    </main>

    <footer class="absolute b-0 w-full h-[5.3em] px-6 py-12 bg-slate-200 text-right">
      <div class="flex">
        <%= if @current_scope && (%{role: :tech} = @current_scope.user) do %>
          <.link class="underline text-slate-600" href={~p"/tech"}>
            Dashboard
          </.link>
        <% else %>
          <.link
            class={["underline text-slate-600", if(@current_scope, do: "hidden")]}
            href={~p"/users/log-in"}
          >
            Admin login
          </.link>
        <% end %>
        <p class="ms-auto">
          <a class="underline" href={~p"/terms-and-conditions"}>Terms of use</a>
        </p>
      </div>
      <p class="text-center text-sm text-slate-600">
        Signbank v{Application.spec(:signbank, :vsn)}
      </p>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  attr :class, :string, default: ""
  attr :mobile, :boolean, default: false
  attr :rest, :global

  def nav(assigns) do
    # TODO: fix up mobile menu look; the white boxes are weird
    # consider using a drawer instead https://daisyui.com/components/drawer/
    assigns =
      assign(
        assigns,
        :base_class,
        if assigns.mobile do
          "hidden menu menu-content w-full flex bg-purple text-yellow"
        else
          "hidden md:flex flex-horizonal gap-4 mr-8"
        end
      )

    ~H"""
    <ul class={[@base_class, @class]} {@rest}>
      <li>
        <form action="/dictionary/sign" method="GET">
          <div class="field has-addons text-black">
            <div class="control has-icons-right">
              <input
                class="input"
                type="text"
                name="q"
                placeholder={gettext("Search by English keyword…")}
              />
            </div>
            <div class="control">
              <button class="button">
                <.icon name="hero-magnifying-glass" class="size-6 bg-yellow" />
              </button>
            </div>
          </div>
        </form>
      </li>
      <.nav_item mobile={@mobile}>
        {gettext("About")}
        <:children>
          <.nav_item href={~p"/about/community"}>
            {gettext("Community")}
          </.nav_item>
          <.nav_item href={~p"/about/history"}>
            {gettext("History")}
          </.nav_item>
          <.nav_item href={~p"/about/acknowledgements"}>
            {gettext("Acknowledgements")}
          </.nav_item>
        </:children>
      </.nav_item>

      <.nav_item mobile={@mobile}>
        {gettext("Research")}
        <:children>
          <.nav_item href={~p"/research/corpus"}>{gettext("Corpus")}</.nav_item>
          <.nav_item href={~p"/research/vocabulary"}>{gettext("Vocabulary")}</.nav_item>
          <.nav_item href={~p"/about/grammar"}>{gettext("Grammar")}</.nav_item>
          <.nav_item href={~p"/dictionary/search"}>{gettext("Advanced search")}</.nav_item>
        </:children>
      </.nav_item>
    </ul>
    """
  end

  slot :inner_block, required: true
  slot :children, required: false
  attr :href, :string, default: "#"
  attr :class, :string, default: ""
  attr :mobile, :boolean, default: false
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the parent"

  defp nav_item(assigns) do
    if Enum.any?(assigns.children) do
      ~H"""
      <li class={[if(!@mobile, do: "dropdown dropdown-end "), @class]} {@rest}>
        <.link tabindex="0" role="button" href="#" class="m-1">
          {render_slot(@inner_block)}
        </.link>
        <ul
          tabindex="0"
          class={[
            if(!@mobile, do: "dropdown-content"),
            "menu bg-base-100 text-slate-900 z-1 w-52 p-2 shadow-sm"
          ]}
        >
          {render_slot(@children)}
        </ul>
      </li>
      """
    else
      ~H"""
      <li class={@class}><.link href={@href}>{render_slot(@inner_block)}</.link></li>
      """
    end
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
