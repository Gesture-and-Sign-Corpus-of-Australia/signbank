defmodule Signbank.Repo.Migrations.RemoveDefinitionPosUniqueConstraint do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    # Removing because it makes it harder to write UI for sorting definitions
    # also its not a very important thing to enforce anyway
    drop index("definitions", [:sign_id, :role, :pos],
           name: :definition_pos_unique_index,
           concurrently: true
         )
  end

  def down do
    create unique_index(
             :definitions,
             [:sign_id, :role, :pos],
             name: :definition_pos_unique_index,
             concurrently: true
           )
  end
end
