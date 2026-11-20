defmodule Signbank.Workers.CorpusLoader do
  @moduledoc """
  The corpus loader assumes that in the corpus is made up of
  `.mp4` video files and `.eaf` ELAN transcription files. There is
  no reason this couldn't be extended to allow other file formats.
  """
  use Oban.Worker
  import Ecto.Query, warn: false
  import Meeseeks.CSS
  alias Signbank.Corpus
  alias Signbank.Repo

  @backfill_delay 5
  @overlap_tolerance_ms 20
  @insert_batch_size 1_000

  @doc """
  Parse all annotations in an `.eaf` file and store each one as a
  `Corpus.Example` (timecodes into the matching `.mp4`; no clips are cut).
  """
  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"backfill" => true} = args}) do
    eaf = Map.get(args, "eaf", Enum.at(corpus_eafs(), 0))

    with :ok <- perform(%Oban.Job{args: %{"eaf" => eaf}}) do
      case fetch_next(eaf) do
        next_eaf when is_binary(next_eaf) ->
          %{eaf: next_eaf, backfill: true}
          |> new(schedule_in: @backfill_delay)
          |> Oban.insert()

        nil ->
          :ok
      end
    end
  end

  def perform(%Oban.Job{args: %{"eaf" => eaf}}) do
    source_video_id = String.replace(eaf, ".eaf", ".mp4")

    xml =
      Meeseeks.parse(
        File.read!(Path.join(Application.fetch_env!(:signbank, :corpus_root), eaf)),
        :xml
      )

    timeslots =
      for timeslot <- Meeseeks.all(xml, css("TIME_SLOT")) do
        %{
          id: Meeseeks.attr(timeslot, "TIME_SLOT_ID"),
          value: Meeseeks.attr(timeslot, "TIME_VALUE")
        }
      end

    examples =
      for el <- Meeseeks.all(xml, annotation_selector()), reduce: [] do
        processed ->
          example = %{
            annotation_text: Meeseeks.text(el),
            source_video_id: source_video_id,
            start_ms: get_timecode(timeslots, Meeseeks.attr(el, "TIME_SLOT_REF1")),
            end_ms: get_timecode(timeslots, Meeseeks.attr(el, "TIME_SLOT_REF2"))
          }

          if overlaps_any?(example, processed), do: processed, else: [example | processed]
      end

    # Replace this video's examples in one go, so a failed run leaves the old ones in place.
    Repo.transaction(fn ->
      clear_existing_examples(source_video_id)
      # Insert in batches
      examples
      |> Enum.reverse()
      |> Enum.chunk_every(@insert_batch_size)
      |> Enum.each(&Repo.insert_all(Corpus.Example, &1))
    end)

    :ok
  end

  # The same sign is often annotated on both the left- and right-hand tiers;
  # only keep one example when the two annotations line up.
  defp overlaps_any?(example, processed) do
    Enum.any?(processed, fn other ->
      example.annotation_text == other.annotation_text and
        abs(example.start_ms - other.start_ms) < @overlap_tolerance_ms and
        abs(example.end_ms - other.end_ms) < @overlap_tolerance_ms
    end)
  end

  def corpus_eafs,
    do:
      :signbank
      |> Application.fetch_env!(:corpus_root)
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, "eaf"))
      |> Enum.sort()

  def fetch_next(eaf) do
    Enum.at(corpus_eafs(), Enum.find_index(corpus_eafs(), &(&1 == eaf)) + 1)
  end

  def clear_existing_examples(source_video_id) do
    Repo.delete_all(from(e in Corpus.Example, where: e.source_video_id == ^source_video_id))
  end

  def tiers_of_interest, do: ["LH-IDgloss", "RH-IDgloss"]

  def annotation_selector,
    do:
      tiers_of_interest()
      |> Enum.map_join(",", fn
        tier_name -> "[TIER_ID=\"#{tier_name}\"] ALIGNABLE_ANNOTATION"
      end)
      |> css()

  def get_timecode(timeslots, timecode_id) do
    timecode = Enum.find(timeslots, &(&1.id == timecode_id)).value
    String.to_integer(timecode)
  end
end
