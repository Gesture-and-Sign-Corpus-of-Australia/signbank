defmodule SignbankWeb.SignLive.LinguisticView do
  use SignbankWeb, :live_view
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(params, _session, socket) do
    {:ok, assign(socket, :params, params)}
  end

  @impl true
  def handle_params(%{"id" => id_gloss}, _, socket) do
    case Dictionary.get_sign_by_id_gloss(id_gloss, socket.assigns.current_user) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "You do not have permission to access this page, please log in.")
         |> redirect(to: ~p"/users/log_in")}

      sign ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:sign, sign)}
    end
  end

  # TODO: fix the page title
  defp page_title(:show), do: gettext("Show sign")
  defp page_title(:edit), do: gettext("Edit sign")

  defp list_flags(flags) do
    with flags <- flags |> Map.filter(fn {_, v} -> v end) |> Map.keys() do
      Enum.join(
        if(Enum.empty?(flags), do: ["none"], else: flags),
        ", "
      )
    end
  end

  defp generate_initial_final_text(initial, final) when initial == final or final in ["", nil],
    do: "#{initial}"

  defp generate_initial_final_text(initial, final), do: "#{initial} → #{final}"

  defp video_frame_type(sign) do
    cond do
      sign.english_entry -> "fingerspelled"
      sign.is_signed_english_only -> "Signed English-only"
      sign.type == :citation -> "citation"
      sign.type == :variant -> "variant"
    end
  end

  defp video_frame_class(sign) do
    if sign.english_entry do
      "english_entry"
    else
      if sign.is_signed_english_only do
        "se_only"
      else
        Atom.to_string(sign.type)
      end
    end
  end

  defp bool_to_word(true), do: gettext("yes")
  defp bool_to_word(false), do: gettext("no")
  defp bool_to_word(_), do: gettext("unknown")
end
