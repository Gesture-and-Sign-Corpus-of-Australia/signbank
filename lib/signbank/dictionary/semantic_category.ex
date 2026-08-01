defmodule Signbank.Dictionary.SemanticCategory do
  @moduledoc false
  use Ecto.Schema
  alias Signbank.Dictionary

  schema "semantic_categories" do
    field :name, :string
    many_to_many :signs, Dictionary.Sign, join_through: "signs_semantic_categories"
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:name])
    |> Ecto.Changeset.unique_constraint(:name, name: :semantic_categories_pkey)
  end
end
