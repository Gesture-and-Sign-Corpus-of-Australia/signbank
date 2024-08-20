# excellent_migrations:safety-assured-for-this-file raw_sql_executed
defmodule Signbank.Repo.Migrations.EnablePgTrgm do
  use Ecto.Migration

  def up do
    execute("create extension if not exists pg_trgm;")
  end

  def down do
    execute("drop extension if exists pg_trgm;")
  end
end
