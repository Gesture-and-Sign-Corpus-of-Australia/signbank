defmodule SignbankWeb.SignLive.BasicView do
  use SignbankWeb, :live_view

  import SignbankWeb.Gettext
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id_gloss} = params, _, socket) do
    search_query = Map.get(params, "q")

    socket =
      assign(
        socket,
        :search_results,
        if is_nil(search_query) do
          []
        else
          {:ok, search_results} = Dictionary.get_sign_by_keyword!(search_query)
          search_results
        end
      )

    # TODO: this is really quite broken, it doesn't take into account the logged in user
    sign = Dictionary.get_sign_by_id_gloss!(id_gloss)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:sign, sign)
     |> assign(:search_query, search_query)}
  end

  # TODO: fix the page title
  defp page_title(:show), do: gettext("Show sign")
  defp page_title(:edit), do: gettext("Edit sign")
end
