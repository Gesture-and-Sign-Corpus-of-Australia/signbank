defmodule Signbank.Corpus do
  @moduledoc """
  The Corpus context.
  """
  import Ecto.Query, warn: false
  alias Signbank.Corpus.Example
  alias Signbank.Repo

  @doc """
  Returns a list of examples from the corpus for a given annotation ID gloss.
  """
  def examples_for_gloss(gloss) do
    Repo.all(
      from e in Example,
        where: ^gloss == e.annotation_text
    )
  end

  def make_example(gloss, url) do
    Repo.insert(%Example{
      annotation_text: gloss,
      video_url: url
    })
  end
end
