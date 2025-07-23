defmodule Signbank.Repo.Migrations.MoveKeywordsFieldToTable do
  use Ecto.Migration

  def up do
    execute("insert into sign_keywords(sign_id, text, inserted_at, updated_at)
    select id, unnest(keywords), NOW(), NOW() from signs")

    alter table(:signs) do
      remove :keywords
    end
  end

  def down do
    alter table(:signs) do
      add :keywords, {:array, :string}
    end

    execute("update signs s
    set keywords = sq.keywords
    from (
      select s.id as id, array_agg(k.text) as keywords
      from signs s
      join sign_keywords k
        on k.sign_id = s.id
      group by s.id
    ) as sq
    where s.id = sq.id")
  end
end
