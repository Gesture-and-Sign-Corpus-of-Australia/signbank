defmodule Signbank.Dictionary.SignRelation do
  @moduledoc """
  A relationship between two signs (e.g., antonym)
  """
  use Ecto.Schema
  use Gettext, backend: Signbank.Gettext

  import Ecto.Changeset

  @relation_types [
    :antonym,
    :synonym,
    :see_also
  ]
  def relation_types, do: @relation_types

  def region_to_string(:antonym), do: gettext("Antonym")
  def region_to_string(:synonym), do: gettext("Synonym")
  def region_to_string(:see_also), do: gettext("See also")

  schema "sign_relations" do
    belongs_to :sign_a, Signbank.Dictionary.Sign
    belongs_to :sign_b, Signbank.Dictionary.Sign

    field :type, Ecto.Enum, values: @relation_types

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(definition, attrs) do
    required_fields = [
      :sign_id,
      :region
    ]

    definition
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:id, name: "sign_regions_pkey")
    |> unique_constraint([:sign_id, :region], name: "sign_sign_regions_unique")
  end
end
