# TODO: this is not namespaced correctly
defmodule SignbankWeb.CorpusExamples do
  @moduledoc """
  Shows a list of examples from the Auslan corpus.
  """
  use SignbankWeb, :live_component
  alias Signbank.Corpus
  alias Signbank.ElanParser

  attr :version, :atom, default: :inline
  attr :gloss, :atom, default: :inline

  def render(assigns) do
    assigns =
      assign(
        assigns,
        examples: Corpus.examples_for_gloss(assigns.gloss)
      )

    ~H"""
    <div>
      <%= if !Enum.empty?(@examples) do %>
        <%= if @version == :inline do %>
          inline version
          <div :for={example <- @examples}>
            <%!-- <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{example.video_url}"} /> --%>
            {example.video_url}
          </div>
        <% else %>
          <%!-- <.button
            onclick={"corpus_examples_modal__#{@gloss}.showModal()"}
          >Show examples for {@gloss}</.button> --%>

          <.modal_examples gloss={@gloss} examples={@examples} />
        <% end %>
      <% end %>
    </div>
    """
  end

  def modal_examples(assigns) do
    ~H"""
    <.modal id={"corpus_examples_modal__#{@gloss}"} button_label="Show corpus examples">
      <div class="space-y-6">
        <div :for={example <- @examples}>
          <.example_with_elan example={example} id={"example_#{example.id}"} />
        </div>
      </div>
    </.modal>
    """
  end

  attr :example, :map, required: true
  attr :id, :string, default: nil

  def example_with_elan(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "example_#{assigns.example.id}" end)
      |> assign_new(:elan_data, fn -> load_elan_for_example(assigns.example) end)
      # For quick testing, fall back to demo ELAN data if none is found on disk
      |> then(fn a -> assign(a, :elan_data, a.elan_data || demo_elan_data()) end)

    ~H"""
    <div class="space-y-4 mb-8">
      <!-- Video player -->
      <video
        id={"video_#{@id}"}
        muted
        controls
        class="w-full max-w-2xl"
        phx-hook="VideoPlayer"
      >
        <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{@example.video_url}"} />
      </video>

      <!-- ELAN viewer (if annotations exist) -->
      <%= if @elan_data do %>
        <div class="border border-gray-300 rounded-lg p-4 bg-white">
          <h4 class="font-semibold mb-2">Annotations</h4>
          <.live_component
            module={SignbankWeb.ElanViewer}
            id={"elan_#{@id}"}
            tiers={@elan_data.tiers}
            duration={@elan_data.duration}
            video_id={"video_#{@id}"}
          />
        </div>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_info({:seek_video, time_ms}, socket) do
    # Send JavaScript command to seek video to specific time
    {:noreply,
     push_event(socket, "seek_video", %{
       video_id: socket.assigns.video_id,
       time: time_ms / 1000
     })}
  end

  # Load ELAN data for a specific example
  defp load_elan_for_example(example) do
    # Try to find corresponding .eaf file based on video_url
    case example do
      %{video_url: video_url} when is_binary(video_url) ->
        # Replace video extension with .eaf
        eaf_path = String.replace(video_url, ~r/\.(mp4|mov|avi)$/i, ".eaf")
        load_elan_file(eaf_path)

      _ ->
        nil
    end
  end

  defp load_elan_file(path) do
    media_dir = Application.get_env(:signbank, :media_dir, "priv/static/media")
    full_path = Path.join(media_dir, path)

    case File.read(full_path) do
      {:ok, content} ->
        ElanParser.parse(content)

      {:error, _reason} ->
        # No ELAN file found
        nil
    end
  rescue
    _ ->
      # If parsing fails, return nil
      nil
  end

  # Demo data to render the ELAN viewer even if no .eaf is available
  defp demo_elan_data do
    %{
      duration: 60_000,
      tiers: [
        %{name: "RH-IDgloss", annotations: [
          %{start: 0, end: 1_500, text: "HELLO"},
          %{start: 2_000, end: 3_500, text: "WORLD"}
        ]},
        %{name: "LH-IDgloss", annotations: [
          %{start: 0, end: 1_500, text: "HELLO"},
          %{start: 2_000, end: 3_500, text: "WORLD"}
        ]},
        %{name: "LitTransl", annotations: [
          %{start: 0, end: 3_500, text: "Hello world"}
        ]},
        %{name: "FreeTransl", annotations: [
          %{start: 0, end: 3_500, text: "Hello world"}
        ]}
      ]
    }
  end

  # TODO: delete commented out code
  # def render(assigns) do
  #   examples = :ets.lookup(:corpus_annotations_index, assigns.gloss)
  #   IO.inspect(examples)

  #   assigns =
  #     if Enum.count(examples) > 0 do
  #       [{_gloss, _transcription_filename, [start_ms, end_ms]}|_] = examples
  #       assign(
  #         assigns,
  #         example: %{
  #           start_ms: start_ms,
  #           end_ms: end_ms
  #         }
  #       )
  #     else
  #       assign(
  #         assigns,
  #         example: %{}
  #       )
  #     end
  #   ~H"""
  #   <div>
  #   <%= if @version == :inline do%>
  #     inline version
  #       {Map.get(@example, :start_ms, "nothing")}
  #   <% else %>
  #     <button>See examples for {@gloss}</button>
  #   <% end %>
  #   </div>
  #   """
  # end
end
