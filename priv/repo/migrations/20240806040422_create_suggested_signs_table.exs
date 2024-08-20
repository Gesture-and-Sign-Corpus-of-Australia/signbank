defmodule Signbank.Repo.Migrations.CreateSuggestedSignsTable do
  use Ecto.Migration

  def change do
    create table(:suggested_signs) do
      add :sign_id,
          references(:signs, on_delete: :nothing)

      add :url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
