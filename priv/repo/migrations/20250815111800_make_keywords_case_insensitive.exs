defmodule Signbank.Repo.Migrations.MakeKeywordsCaseInsensitive do
  use Ecto.Migration

  def change do
    alter table(:sign_keywords) do
      modify :text, :citext
    end
  end
end
