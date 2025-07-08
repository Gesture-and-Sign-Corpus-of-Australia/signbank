defmodule Signbank.Corpus.Example do
  @moduledoc """
  An example video segment from a corpus.

  - `:video_url` is
  the location in Signbank's media storage of the trimmed
  example clip.
  - `:source_video_id` is the identifier of the original
  corpus video that the example comes from.
  - `:start_ms` and `:end_ms` are the timecodes
  of the annotation, not including any extra time that the
  video trimmer leaves in the final example clip.
  """
  use Ecto.Schema

  schema "corpus_examples" do
    field :annotation_text, :string
    field :video_url, :string
    field :source_video_id, :string
    field :start_ms, :integer
    field :end_ms, :integer
  end
end
