defmodule VideoScroller do
  @moduledoc """
  Shows a sign and its variants in a carosel.
  """
  use SignbankWeb, :live_component
  import SignbankWeb.MapComponents

  def render(assigns) do
    # if we're on a citation sign, concat it into list with all variants,
    # if we're on a variant then travel up to the headsign and do that
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
        index_of_current_sign: index_of_current_sign,
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
    <div class="entry-page__videos_scroller mb-2">
      <.video_frame id={"variant_video_#{@sign.id}_#{@counter}"} sign={@sign} />
      <div :if={@next_sign_link || @previous_sign_link} class="join flex justify-between items-center">
        <.link
          id="previous_variant"
          class="join-item btn p-2"
          patch={@next_sign_link}
          disabled={!@next_sign_link}
        >
          <.icon name="hero-arrow-left" class="size-6" />
          <span class="text-sm">
            previous variant
          </span>
        </.link>
        <%!-- z-index because only the border of the next button was visible --%>
        <div class="z-10 join-item btn btn-disabled text-black grow-1">
          {@index_of_current_sign + 1} of {citation_and_variants |> Enum.count()} variants
        </div>
        <.link
          id="next_variant"
          class="join-item btn p-2"
          patch={@previous_sign_link}
          disabled={!@previous_sign_link}
        >
          <span class="text-sm">
            next variant
          </span>
          <.icon name="hero-arrow-right" class="size-6" />
        </.link>
      </div>
    </div>
    """
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
      <div class="video-frame__video_wrapper">
        <%= if @sign.active_video do %>
          <video controls muted autoplay width="600">
            <source
              :if={@sign.active_video}
              src={"#{Application.fetch_env!(:signbank, :media_url)}/#{@sign.active_video.url}"}
            />
          </video>
        <% else %>
          <p class="bg-slate-500 w-[600px] aspect-video">This entry has no video</p>
        <% end %>
        <div class="video-frame__sign-type">
          {cond do
            @sign.english_entry -> "fingerspelled"
            @sign.is_signed_english_only -> "Signed English-only"
            @sign.type == :citation -> "citation"
            @sign.type == :variant -> "variant"
          end}
        </div>
        <.australia_map selected={@sign.regions} />
      </div>
    </div>
    """
  end
end
