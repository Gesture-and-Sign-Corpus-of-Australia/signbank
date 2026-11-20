defmodule Signbank.Corpus.Example do
  @moduledoc """
  An example of a sign being used in the corpus.

  Examples are not stored as separate video files; an example is a
  segment of an original corpus video, identified by timecodes.

  - `:annotation_text` is the ID gloss of the annotation.
  - `:source_video_id` is the filename of the original corpus video
  that the example comes from (e.g. `"ARG_c2b_A_M_68_NN_RH_(AKR).mp4"`).
  - `:start_ms` and `:end_ms` are the timecodes of the annotation
  within the source video. Any padding shown around the sign during
  playback is added at display time.
  """
  use Ecto.Schema

  schema "corpus_examples" do
    field :annotation_text, :string
    field :source_video_id, :string
    field :start_ms, :integer
    field :end_ms, :integer
  end
end
