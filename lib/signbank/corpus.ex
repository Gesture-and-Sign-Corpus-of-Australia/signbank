defmodule Signbank.Corpus do
  @moduledoc """
  The Corpus context.
  """
  import Ecto.Query, warn: false
  alias Signbank.Corpus.Example
  alias Signbank.Repo

  # Extra context shown either side of the annotation when an example is played.
  @playback_padding_ms 2_500

  @doc """
  Returns a list of examples from the corpus for a given annotation ID gloss.
  """
  def examples_for_gloss(gloss) do
    Repo.all(
      from e in Example,
        where: ^gloss == e.annotation_text
    )
  end

  @doc """
  The part of the source video to play for an example, in milliseconds:
  the annotation plus `@playback_padding_ms` either side.
  """
  def playback_window(%Example{start_ms: start_ms, end_ms: end_ms}) do
    {max(start_ms - @playback_padding_ms, 0), end_ms + @playback_padding_ms}
  end

  @doc """
  URL of the full source video an example comes from.
  """
  # TODO: update where full corpus videos are hosted; this currently assumes they are
  # uploaded to the media bucket under `corpus/`.
  def source_video_url(%Example{source_video_id: source_video_id}) do
    base =
      Application.get_env(:signbank, :corpus_media_url) ||
        "#{Application.fetch_env!(:signbank, :media_url)}/corpus"

    "#{base}/#{source_video_id}"
  end
end
