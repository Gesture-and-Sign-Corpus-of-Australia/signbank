# TODO: this was from `gen.live`, look over it again
defmodule SignbankWeb.SignLive.Index do
  use SignbankWeb, :live_view
  import SignbankWeb.Gettext

  alias Signbank.Dictionary
  alias Signbank.Dictionary.Sign

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

    query = Map.get(params, "q")
    # TODO: use actual set region preference
    case Dictionary.fuzzy_find_keyword(query, :northern) do
      # if we match a keyword exactly, and its the only match, jump straight to results
      {:ok, [[^query, id_gloss, _]]} ->
        {:noreply, push_patch(socket, to: ~p"/dictionary/sign/#{id_gloss}?q=#{query}")}

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

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit sign"))
    |> assign(:sign, Dictionary.get_sign_by_id_gloss!(id))
  end

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
end
