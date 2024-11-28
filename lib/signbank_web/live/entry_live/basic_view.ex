defmodule SignbankWeb.SignLive.BasicView do
  use SignbankWeb, :live_view
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id_gloss} = params, _, socket) do
    search_term = Map.get(params, "q")

    # TODO: I don't remember where this comes from atm, good sign to rename whatever `n` is meant to be
    # n = Map.get(params, "n")

    case Dictionary.get_sign_by_id_gloss(id_gloss, socket.assigns.current_user) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "You do not have permission to access this page, please log in.")
         |> redirect(to: ~p"/users/log_in")}

      sign ->
        socket =
          assign(
            socket,
            :search_results,
            if is_nil(search_term) do
              []
            else
              {:ok, search_results} = Dictionary.get_sign_by_keyword!(search_term)
              search_results
            end
          )

        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:sign, sign)
         |> assign(:search_term, search_term)}
    end
  end

  # TODO: fix the page title
  defp page_title(:show), do: gettext("Show sign")
  defp page_title(:edit), do: gettext("Edit sign")
end
