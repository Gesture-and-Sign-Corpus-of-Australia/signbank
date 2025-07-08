defmodule SignbankWeb.MaintenanceLive do
  use SignbankWeb, :live_view
  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <ul class="*:mb-4">
        <li>
          <.link class="btn" href={~p"/tech/dashboard"}>LiveDashboard (VM metrics)</.link>
        </li>
        <%!-- <li>
          <button class="btn" phx-click="load-corpus" }>Process corpus</button>
        </li> --%>
      </ul>
      <%!-- <h2>UAT testing checklist</h2> --%>
      <%!-- TODO: generate a checklist from `/priv/testing_checklist.json` --%>
    </Layouts.app>
    """
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  # @impl true
  # def handle_event("load-corpus", _, socket) do
  #   %{}
  #   |> Signbank.Workers.CorpusLoader.new()
  #   |> Oban.insert()

  #   {:noreply, socket}
  # end
end
