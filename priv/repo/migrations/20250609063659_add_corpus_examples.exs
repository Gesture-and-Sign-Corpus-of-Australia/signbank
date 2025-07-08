defmodule Signbank.Repo.Migrations.AddCorpusExamples do
  use Ecto.Migration

  def change do
    create table(:corpus_examples) do
      add :annotation_text, :string
      add :video_url, :string
      add :source_video_id, :string
      add :start_ms, :integer
      add :end_ms, :integer
    end
  end
end
