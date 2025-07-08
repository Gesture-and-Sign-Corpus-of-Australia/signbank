defmodule Signbank.Dictionary.Definition do
  @moduledoc """
  A single definition for a sign. Usually text, can be a video
  """
  use Ecto.Schema
  import Ecto.Changeset

  @roles [
    :general,
    :auslan,
    :noun,
    :verb,
    :modifier,
    :pointing_sign,
    :question,
    :interactive,
    # TODO: move this field to notes table
    :augment,
    # TODO: move this field to notes table
    :popular_explanation,
    # TODO: move this field to notes table
    :note,
    # TODO: move this field to notes table (or maybe text field on Sign)
    :editor_note
  ]

  def roles, do: @roles

  schema "definitions" do
    belongs_to :sign, Signbank.Dictionary.Sign

    field :text, :string
    field :pos, :integer
    field :url, :string

    field :role, Ecto.Enum, values: @roles

    # TODO: figure out a way to handle SL definitions, probably can just set :language appropriately and have url field
    # ISO language code expected
    field :language, :string
    field :published, :boolean, default: false

    field :delete, :boolean, virtual: true

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(definition, attrs, position) do
    required_fields = [
      :text,
      :role,
      :language
    ]

    optional_fields = [
      :published,
      :delete
    ]

    changeset =
      definition
      |> cast(attrs, required_fields ++ optional_fields)
      |> change(pos: position)
      |> validate_required(required_fields)
      |> unique_constraint([:sign_id, :role, :pos], name: "definition_pos_unique_index")

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
