defmodule Signbank.Dictionary.SemanticCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Signbank.Dictionary

  schema "semantic_categories" do
    field :name, :string
    many_to_many :signs, Dictionary.Sign, join_through: "signs_semantic_categories"
  end
end
