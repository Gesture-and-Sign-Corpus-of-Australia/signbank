defmodule Signbank.Dictionary.Morphology do
  @moduledoc """
  The morphology of a sign, actually stored as JSON in the database
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :directional, :boolean
    field :beginning_directional, :boolean
    field :end_directional, :boolean
    field :orientating, :boolean
    field :body_locating, :boolean

    field :is_initialism, :boolean
    field :is_alphabet, :boolean
    field :is_abbreviation, :boolean

    field :is_fingerspelled_word, :boolean

    # TODO: eventually we would like to refactor this information into a table, to properly link signs
    field :blend_of, :string
    field :calque_of, :string
    field :compound_of, :string
    field :idiom_of, :string
    field :initialization_of, :string
    field :multi_sign_expression, :string
  end

  def changeset(phonology, attrs) do
    cast(phonology, attrs, [
      :directional,
      :beginning_directional,
      :end_directional,
      :orientating,
      :body_locating,
      :blend_of,
      :calque_of,
      :compound_of,
      :is_initialism,
      :is_alphabet,
      :is_abbreviation,
      :is_fingerspelled_word,
      :idiom_of,
      :initialization_of,
      :multi_sign_expression
    ])
  end
end
