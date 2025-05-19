defmodule SignbankWeb.Tech.Index do
  use SignbankWeb, :live_view
  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do

    {:noreply, socket}
  end
end
