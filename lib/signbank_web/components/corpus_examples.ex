# TODO: this is not namespaced correctly
defmodule SignbankWeb.CorpusExamples do
  @moduledoc """
  Shows a single example from the Auslan corpus.
  """
  use SignbankWeb, :live_component
  alias Signbank.Corpus
  alias Signbank.ElanParser

  attr :version, :atom, default: :inline
  attr :gloss, :atom, default: :inline

  def render(assigns) do
    ~H"""
    <div>
      <%= if !Enum.empty?(@examples) do %>
        <%= if @version == :inline do %>
          inline version
          <div :for={example <- @examples}>
            {example.source_video_id} ({example.start_ms}–{example.end_ms} ms)
          </div>
        <% else %>
          <button
            type="button"
            class="btn"
            phx-click="randomize_example"
            phx-target={@myself}
          >
            Show corpus examples
          </button>
          <dialog id={"corpus_examples_modal__#{@gloss}"} class="modal">
            <div class="modal-box">
              <%= if @current_example do %>
                <.example_with_elan
                  example={@current_example}
                  id={"example_#{@current_example.id}"}
                />
              <% end %>
              <div class="modal-action">
                <button
                  :if={length(@examples) > 1}
                  type="button"
                  class="btn btn-ghost"
                  phx-click="randomize_example"
                  phx-target={@myself}
                >
                  Show another
                </button>
                <form method="dialog">
                  <button class="btn">Close</button>
                </form>
              </div>
            </div>
          </dialog>
        <% end %>
      <% end %>
    </div>
    """
  end

  attr :example, :map, required: true
  attr :id, :string, default: nil

  def example_with_elan(assigns) do
    {clip_start_ms, clip_end_ms} = Corpus.playback_window(assigns.example)

    assigns =
      assigns
      |> assign(:clip_start, clip_start_ms / 1000)
      |> assign(:clip_end, clip_end_ms / 1000)
      |> assign_new(:id, fn -> "example_#{assigns.example.id}" end)
      |> assign_new(:elan_data, fn -> load_elan_for_example(assigns.example) end)

    ~H"""
    <div class="space-y-4 mb-8">
      <!-- Video player -->
      <video
        id={"video_#{@id}"}
        muted
        controls
        class="w-full max-w-2xl"
        phx-hook="VideoPlayer"
        preload="metadata"
        data-clip-start={@clip_start}
        data-clip-end={@clip_end}
      >
        <source src={"#{Corpus.source_video_url(@example)}#t=#{@clip_start},#{@clip_end}"} />
      </video>

      <!-- ELAN viewer (if annotations exist) -->
      <%= if @elan_data do %>
        <div class="border border-gray-300 rounded-lg p-1 sm:p-4 bg-white">
          <div class="flex items-center justify-between mb-2">
            <h4 class="font-semibold">Annotations</h4>
            <button
              type="button"
              class="btn btn-sm btn-ghost gap-1 w-28"
              onclick={"var el=document.getElementById('elan_#{@id}');if(el){el.querySelector('[data-zoom-fit]').click()}"}
              data-zoom-fit-external={"elan_#{@id}"}
            >
              <span class="text-sm">🔍︎</span> Zoom out
            </button>
          </div>
          <.live_component
            module={SignbankWeb.ElanViewer}
            id={"elan_#{@id}"}
            tiers={@elan_data.tiers}
            duration={@elan_data.duration}
            video_id={"video_#{@id}"}
            highlight={@example.annotation_text}
          />
        </div>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    examples = Corpus.examples_for_gloss(assigns.gloss)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:examples, examples)
     |> assign_new(:current_example, fn -> nil end)}
  end

  def handle_event("randomize_example", _params, socket) do
    current = socket.assigns.current_example
    examples = socket.assigns.examples

    candidates =
      case current do
        nil -> examples
        %{id: current_id} -> Enum.reject(examples, &(&1.id == current_id))
      end

    example = Enum.random(if(candidates == [], do: examples, else: candidates))

    socket =
      socket
      |> assign(:current_example, example)
      |> push_event("open_modal", %{id: "corpus_examples_modal__#{socket.assigns.gloss}"})

    {:noreply, socket}
  end

  def handle_info({:seek_video, time_ms}, socket) do
    # Send JavaScript command to seek video to specific time
    {:noreply,
     push_event(socket, "seek_video", %{
       video_id: socket.assigns.video_id,
       time: time_ms / 1000
     })}
  end

  # Load ELAN data for the part of the source video that is played for this
  # example.
  defp load_elan_for_example(example) do
    case example do
      %{source_video_id: source_video_id} when is_binary(source_video_id) ->
        eaf_filename = String.replace(source_video_id, ~r/\.(mp4|mov|avi)$/i, ".eaf")
        {clip_start, clip_end} = Corpus.playback_window(example)
        load_elan_file(eaf_filename, start_ms: clip_start, end_ms: clip_end)

      _ ->
        nil
    end
  end

  defp load_elan_file(filename, opts) do
    # The .eaf files live alongside the corpus videos unless :eaf_dir says otherwise
    media_dir =
      Application.get_env(:signbank, :eaf_dir) || Application.fetch_env!(:signbank, :corpus_root)
    full_path = Path.join(media_dir, filename)

    case File.read(full_path) do
      {:ok, content} ->
        ElanParser.parse(content,
          tiers: ElanParser.relevant_tiers(),
          start_ms: Keyword.get(opts, :start_ms),
          end_ms: Keyword.get(opts, :end_ms)
        )

      {:error, reason} ->
        IO.warn(reason)
        nil
    end
  rescue
    _ -> nil
  end
end
