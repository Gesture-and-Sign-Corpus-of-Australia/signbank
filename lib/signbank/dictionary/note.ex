defmodule Signbank.Dictionary.Note do
  @moduledoc """
  A note about a sign, e.g. an augmented meaning or an editor's note.

  Unlike definitions, notes belong to a single sign.
  """
  use Ecto.Schema
  use Gettext, backend: Signbank.Gettext
  import Ecto.Changeset

  @types [
    :augment,
    :popular_explanation,
    :note,
    :editor_note
  ]

  # Note types that may be shown to the public (when published)
  @public_types [
    :augment,
    :note
  ]

  def types, do: @types
  def public_types, do: @public_types

  def type_to_string(:augment), do: gettext("Augmented meaning")
  def type_to_string(:popular_explanation), do: gettext("Popular explanation")
  def type_to_string(:note), do: gettext("Note")
  def type_to_string(:editor_note), do: gettext("Editor note")

  schema "notes" do
    belongs_to :sign, Signbank.Dictionary.Sign

    field :type, Ecto.Enum, values: @types
    field :text, :string
    field :pos, :integer
    field :published, :boolean, default: false

    field :delete, :boolean, virtual: true

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(note, attrs, position) do
    required_fields = [:type, :text]
    optional_fields = [:published, :delete]

    changeset =
      note
      |> cast(attrs, required_fields ++ optional_fields)
      |> change(pos: position)
      |> validate_required(required_fields)

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
