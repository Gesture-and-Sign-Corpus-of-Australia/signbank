defmodule Signbank.Repo.Migrations.CreateDescriptionOnSuggestedSigns do
  use Ecto.Migration

  def change do
    alter table(:suggested_signs) do
      add :description, :text
    end

    alter table(:signs) do
      remove :suggested_signs_description
    end
  end
end
