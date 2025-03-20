# TODO: this was from `gen.live`, look over it again
defmodule SignbankWeb.SignLive.Index do
  use SignbankWeb, :live_view

  alias Signbank.Dictionary
  alias Signbank.Dictionary.Sign

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :signs, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> assign(:inexact_matches, [])
      |> assign(:error, nil)

    search_term = Map.get(params, "q")

    handshape = Map.get(params, "hs")
    location = Map.get(params, "loc")

    if handshape || location do
      case Dictionary.get_sign_by_phon_feature!(params) do
        [] ->
          {:noreply,
           socket
           |> apply_action(socket.assigns.live_action, params)
           |> assign(:error, gettext("No matches found."))}

        [first | _] ->
          {:noreply,
           push_patch(socket,
             to: ~p"/dictionary/sign/#{first.id_gloss}?#{persist_query_params(params)}"
           )}
      end
    else
      # TODO: we need to use `n` to get to a specific match number, but right now we can't
      # see other matches and they're not sorted properly anyway
      case Dictionary.fuzzy_find_keyword(search_term, socket.assigns.current_user) do
        # if we match a keyword exactly, and its the only match, jump straight to results
        {:ok, [[^search_term, id_gloss, _]]} ->
          {:noreply,
           push_patch(socket,
             to: ~p"/dictionary/sign/#{id_gloss}?#{%{"q" => search_term}}"
           )}

        {:ok, inexact_matches} ->
          {:noreply,
           socket
           |> apply_action(socket.assigns.live_action, params)
           |> assign(:inexact_matches, inexact_matches)}

        {:err, msg} ->
          {:noreply,
           socket
           |> apply_action(socket.assigns.live_action, params)
           |> assign(:error, msg)}
      end
    end
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, gettext("Edit sign"))
  #   |> assign(:sign, Dictionary.get_sign_by_id_gloss!(id))
  # end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New sign"))
    |> assign(:sign, %Sign{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("List of entries"))
    |> assign(:sign, nil)
  end

  @impl true
  def handle_info({SignbankWeb.SignLive.FormComponent, {:saved, sign}}, socket) do
    {:noreply, stream_insert(socket, :signs, sign)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sign = Dictionary.get_sign!(id)
    {:ok, _} = Dictionary.delete_sign(sign)

    {:noreply, stream_delete(socket, :signs, sign)}
  end

  def persist_query_params(params) do
    Map.filter(params, fn {key, val} -> key in ["hs", "loc", "q"] and val not in ["", nil] end)
  end
end
