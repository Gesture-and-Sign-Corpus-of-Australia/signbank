# TODO: this is not namespaced correctly
defmodule SignbankWeb.CorpusExamples do
  @moduledoc """
  Shows a list of examples from the Auslan corpus.
  """
  use SignbankWeb, :live_component
  alias Signbank.Corpus

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
      <div>
        <div :for={example <- @examples}>
          <video muted controls>
            <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{example.video_url}"} />
            <%!-- {example.video_url} --%>
          </video>
        </div>
      </div>
    </.modal>
    """
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
