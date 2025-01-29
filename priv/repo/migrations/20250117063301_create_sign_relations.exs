defmodule Signbank.Repo.Migrations.CreateSignRelations do
  use Ecto.Migration

  def change do
    create table(:sign_relations) do
      add :sign_a_id, references(:signs, on_delete: :nothing)
      add :sign_b_id, references(:signs, on_delete: :nothing)

      add :type, :text

      timestamps(type: :utc_datetime)
    end
  end
end
