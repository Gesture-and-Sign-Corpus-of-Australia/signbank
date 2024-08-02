defmodule Signbank.Repo.Migrations.AddUrlFieldToDefinitions do
  use Ecto.Migration

  def change do
    alter table(:definitions) do
      add :url, :text, null: true
    end
  end
end
