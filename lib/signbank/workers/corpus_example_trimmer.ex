defmodule Signbank.Workers.CorpusExampleTrimmer do
  @moduledoc """
  The corpus loader assumes that in the corpus is made up of
  `.mp4` video files and `.eaf` ELAN transcription files. There is
  no reason this couldn't be extended to allow other file formats.
  """
  use Oban.Worker, queue: :ffmpeg
  import Signbank.Workers.Util, only: [upload: 1]

  alias Signbank.Corpus
  alias Signbank.Repo

  @clip_padding_ms 2.5 * 1000

  @impl Oban.Worker
  @doc """
  Create a trimmed clip for an annotation.
  """
  def perform(%Oban.Job{
        args: %{
          "eaf" => eaf,
          "annotation_text" => annotation_text,
          "start_ms" => start_ms,
          "end_ms" => end_ms
        }
      }) do
    source_video = String.replace(eaf, ".eaf", ".mp4")
    output = "corpus_examples/#{annotation_text}_#{start_ms}-#{end_ms}__#{source_video}"

    # TODO: better check for file existence and option to ignore that to generate a new one, as an optional argument
    # file.exists? check needs to take both S3 and upload staging dir into account, maybe
    # could also ignore the staging dir, if ffmpeg fails it fails; oban'll retry the job until it gives up but the
    # file will eventually be uploaded
    if File.exists?(output) do
      {:discard, "Output file already exists"}
    else
      # TODO: I think System.cmd will throw on ffmpeg failure; but there may be some failures we need to check for to provide a better error message
      trim(annotation_text, start_ms, end_ms, source_video, output)

      upload(output)

      # TODO: store videos locally and have a periodic job to upload them to S3
      %Corpus.Example{
        annotation_text: annotation_text,
        video_url: Path.relative_to(output, Application.fetch_env!(:signbank, :upload_staging)),
        source_video_id: source_video,
        start_ms: start_ms,
        end_ms: end_ms
      }
      |> Repo.insert()

      :ok
    end
  end

  def trim(_annotation_text, start_ms, end_ms, source_video, output) do
    clip_start = (start_ms - @clip_padding_ms) / 1000
    clip_length = (end_ms - start_ms + @clip_padding_ms * 2) / 1000

    System.cmd(
      "ffmpeg",
      [
        "-ss",
        "#{clip_start}",
        "-i",
        Path.join(Application.fetch_env!(:signbank, :corpus_root), source_video),
        "-c",
        "copy",
        "-t",
        "#{clip_length}",
        "-n",
        Path.join(Application.fetch_env!(:signbank, :upload_staging), output)
      ],
      stderr_to_stdout: true
    )
  end
end
