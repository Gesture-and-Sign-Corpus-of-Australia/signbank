defmodule Signbank.Repo.Migrations.RemoveCorpusExampleVideoUrl do
  use Ecto.Migration

  def change do
    alter table(:corpus_examples) do
      remove :video_url, :string
    end
  end
end
