defmodule Signbank.Repo.Migrations.CreateSemanticCategories do
  use Ecto.Migration

  def change do
    create table(:semantic_categories) do
      add :name, :string
    end

    create table(:signs_semantic_categories) do
      add :sign_id,
          references(:signs, on_delete: :nothing)

      add :semantic_category_id,
          references(:semantic_categories, on_delete: :nothing)
    end
  end
end
