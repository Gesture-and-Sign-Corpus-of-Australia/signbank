defmodule Signbank.Repo.Migrations.MakeIDGlossCaseInsensitive do
  use Ecto.Migration

  def change do
    alter table("signs") do
      modify :id_gloss, :citext, from: :text
    end
  end
end
