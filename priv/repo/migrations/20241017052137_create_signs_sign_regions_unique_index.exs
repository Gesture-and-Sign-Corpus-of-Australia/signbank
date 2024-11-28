defmodule Signbank.Repo.Migrations.CreateSignsSignRegionsUniqueIndex do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create unique_index(:sign_regions, [:sign_id, :region], concurrently: true)
  end
end
