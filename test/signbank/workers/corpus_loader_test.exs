defmodule Signbank.Workers.CorpusLoaderTest do
  # Not async: the test changes the :corpus_root application env
  use Signbank.DataCase, async: false

  alias Signbank.Corpus.Example
  alias Signbank.Workers.CorpusLoader

  # HOUSE is annotated on both hands at (almost) the same time, so it should
  # only produce one example. DOG only appears on the right hand.
  @eaf """
  <?xml version="1.0" encoding="UTF-8"?>
  <ANNOTATION_DOCUMENT>
    <HEADER/>
    <TIME_ORDER>
      <TIME_SLOT TIME_SLOT_ID="ts1" TIME_VALUE="1000"/>
      <TIME_SLOT TIME_SLOT_ID="ts2" TIME_VALUE="1500"/>
      <TIME_SLOT TIME_SLOT_ID="ts3" TIME_VALUE="1005"/>
      <TIME_SLOT TIME_SLOT_ID="ts4" TIME_VALUE="1510"/>
      <TIME_SLOT TIME_SLOT_ID="ts5" TIME_VALUE="4000"/>
      <TIME_SLOT TIME_SLOT_ID="ts6" TIME_VALUE="4800"/>
    </TIME_ORDER>
    <TIER TIER_ID="RH-IDgloss">
      <ANNOTATION><ALIGNABLE_ANNOTATION ANNOTATION_ID="a1" TIME_SLOT_REF1="ts1" TIME_SLOT_REF2="ts2"><ANNOTATION_VALUE>HOUSE</ANNOTATION_VALUE></ALIGNABLE_ANNOTATION></ANNOTATION>
      <ANNOTATION><ALIGNABLE_ANNOTATION ANNOTATION_ID="a2" TIME_SLOT_REF1="ts5" TIME_SLOT_REF2="ts6"><ANNOTATION_VALUE>DOG</ANNOTATION_VALUE></ALIGNABLE_ANNOTATION></ANNOTATION>
    </TIER>
    <TIER TIER_ID="LH-IDgloss">
      <ANNOTATION><ALIGNABLE_ANNOTATION ANNOTATION_ID="a3" TIME_SLOT_REF1="ts3" TIME_SLOT_REF2="ts4"><ANNOTATION_VALUE>HOUSE</ANNOTATION_VALUE></ALIGNABLE_ANNOTATION></ANNOTATION>
    </TIER>
  </ANNOTATION_DOCUMENT>
  """

  setup do
    corpus_root =
      Path.join(System.tmp_dir!(), "signbank_corpus_test_#{System.unique_integer([:positive])}")

    File.mkdir_p!(corpus_root)
    File.write!(Path.join(corpus_root, "TEST.eaf"), @eaf)

    previous = Application.get_env(:signbank, :corpus_root)
    Application.put_env(:signbank, :corpus_root, corpus_root)

    on_exit(fn ->
      Application.put_env(:signbank, :corpus_root, previous)
      File.rm_rf!(corpus_root)
    end)

    :ok
  end

  defp run_loader, do: CorpusLoader.perform(%Oban.Job{args: %{"eaf" => "TEST.eaf"}})

  defp examples do
    Repo.all(from e in Example, order_by: e.start_ms)
  end

  test "stores timecodes for each annotation without cutting clips" do
    assert :ok = run_loader()

    assert [
             %Example{
               annotation_text: "HOUSE",
               source_video_id: "TEST.mp4",
               start_ms: 1000,
               end_ms: 1500
             },
             %Example{
               annotation_text: "DOG",
               source_video_id: "TEST.mp4",
               start_ms: 4000,
               end_ms: 4800
             }
           ] = examples()
  end

  test "re-running the loader replaces examples instead of duplicating them" do
    assert :ok = run_loader()
    assert :ok = run_loader()

    assert length(examples()) == 2
  end
end
