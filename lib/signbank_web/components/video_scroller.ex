defmodule VideoScroller do
  @moduledoc """
  Shows a sign and its variants in a carosel.
  """
  use SignbankWeb, :live_component

  def render(assigns) do
    # if we're on a citation sign, concat it into list with all variants, if we're on a variant then travel up to the headsign and do that
    citation_sign =
      if assigns.sign.type == :citation do
        assigns.sign
      else
        assigns.sign.citation
      end

    citation_and_variants =
      [citation_sign]
      |> Enum.concat(citation_sign.variants)
      |> Enum.sort_by(& &1.id_gloss)

    index_of_current_sign =
      Enum.find_index(citation_and_variants, &(&1.id_gloss == assigns.sign.id_gloss))

    assigns =
      assign(
        assigns,
        citation_and_variants: citation_and_variants,
        next_sign_link:
          if index_of_current_sign > 0 do
            case Enum.fetch(citation_and_variants, index_of_current_sign - 1) do
              {:ok, s} -> ~p"/dictionary/sign/#{s.id_gloss}"
              :error -> nil
            end
          else
            nil
          end,
        previous_sign_link:
          case Enum.fetch(citation_and_variants, index_of_current_sign + 1) do
            {:ok, s} -> ~p"/dictionary/sign/#{s.id_gloss}"
            :error -> nil
          end
      )

    ~H"""
    <div class="entry-page__videos_scroller">
      <.link
        :if={@next_sign_link}
        id="previous_variant"
        class="entry-page__videos_scroller_slide_buttons"
        patch={@next_sign_link}
        disabled={!@next_sign_link}
        aria-label="previous variant"
      >
        <Heroicons.arrow_left class="icon--small" />
      </.link>
      <.link
        :if={@previous_sign_link}
        id="next_variant"
        class="entry-page__videos_scroller_slide_buttons"
        patch={@previous_sign_link}
        disabled={!@previous_sign_link}
        aria-label="next variant"
      >
        <Heroicons.arrow_right class="icon--small" />
      </.link>
      <.video_frame id={"variant_video_#{@sign.id}_#{@counter}"} sign={@sign} />
    </div>
    """
  end

  def handle_event("previous", _, socket) do
    {:noreply, socket |> assign(counter: socket.assigns.counter - 1)}
  end

  def handle_event("next", _, socket) do
    # send(self(), {:updated_card, %{socket.assigns.card | title: title}})
    {:noreply, socket |> assign(counter: socket.assigns.counter + 1)}
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

  defp video_frame(assigns) do
    # TODO: refactor along with linguistic_view.html.heex
    ~H"""
    <div id={"video_#{@id}"} class={["video-frame", video_frame_class(@sign)]}>
      <%!-- TODO: refactor to support variant videos (we want to include the thing with the multiple videos, this may require svelte) --%>
      <div class="video-frame__video_wrapper">
        <video controls muted autoplay width="600">
          <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{Enum.at(@sign.videos,0).url}"} />
        </video>
        <div class="video-frame__sign-type">
          <%= cond do
            @sign.english_entry -> "fingerspelled"
            @sign.is_signed_english_only -> "se_only"
            @sign.type == :citation -> "citation"
            @sign.type == :variant -> "variant"
          end %>
        </div>
        <.australia_map selected={@sign.regions} />
      </div>
    </div>
    """
  end
end
