defmodule Signbank.Repo.Migrations.CreateUsersAuthTablesIndexes do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create unique_index(:users, [:email], concurrently: true)

    create index(:users_tokens, [:user_id], concurrently: true)
    create unique_index(:users_tokens, [:context, :token], concurrently: true)
  end
end
