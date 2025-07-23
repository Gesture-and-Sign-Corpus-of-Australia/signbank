defmodule Signbank.Repo.Migrations.CreateKeywordsTable do
  use Ecto.Migration

  def change do
    create table(:sign_keywords) do
      add :text, :text

      add :sign_id,
          references(:signs, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
