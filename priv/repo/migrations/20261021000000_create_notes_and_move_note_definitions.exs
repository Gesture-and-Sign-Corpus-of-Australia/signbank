defmodule Signbank.Repo.Migrations.CreateNotesAndMoveNoteDefinitions do
  use Ecto.Migration

  @note_types ~w(augment popular_explanation note editor_note)

  def up do
    create table(:notes) do
      add :sign_id, references(:signs, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :text, :text
      add :pos, :integer
      add :published, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:notes, [:sign_id])

    flush()

    # Notes are text-only. Refuse to run rather than silently drop a video URL
    # that someone attached to a note-type definition.
    %{rows: [[with_url]]} =
      repo().query!(
        "select count(*) from definitions where role = any($1) and url is not null and url <> ''",
        [@note_types]
      )

    if with_url > 0 do
      raise "#{with_url} note-type definition(s) have a url; resolve them before migrating"
    end

    execute("""
    insert into notes (sign_id, type, text, pos, published, inserted_at, updated_at)
    select sign_id, role, text, pos, published, inserted_at, updated_at
    from definitions
    where role in ('augment', 'popular_explanation', 'note', 'editor_note')
    """)

    execute("""
    delete from definitions
    where role in ('augment', 'popular_explanation', 'note', 'editor_note')
    """)
  end

  def down do
    execute("""
    insert into definitions (sign_id, role, text, pos, published, language, inserted_at, updated_at)
    select sign_id, type, text, pos, published, 'en', inserted_at, updated_at
    from notes
    """)

    drop table(:notes)
  end
end
