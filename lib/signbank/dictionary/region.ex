defmodule Signbank.Dictionary.SignRegion do
  @moduledoc """
  A single region for a sign.
  """
  use Ecto.Schema
  use Gettext, backend: Signbank.Gettext

  import Ecto.Changeset

  @regions [
    :no_region,
    :unknown,
    :not_applicable,
    :australia_wide,
    :northern_dialect,
    :queensland,
    :new_south_wales,
    :southern_dialect,
    :victoria,
    :western_australia,
    :south_australia,
    :tasmania
  ]
  def regions, do: @regions

  def region_to_string(:no_region), do: gettext("No region")
  def region_to_string(:unknown), do: gettext("Unknown")
  def region_to_string(:not_applicable), do: gettext("Not applicable")
  def region_to_string(:australia_wide), do: gettext("Australia-wide")
  def region_to_string(:northern_dialect), do: gettext("Northern dialect")
  def region_to_string(:queensland), do: gettext("Queensland")
  def region_to_string(:new_south_wales), do: gettext("New South Wales")
  def region_to_string(:southern_dialect), do: gettext("Southern Dialect")
  def region_to_string(:victoria), do: gettext("Victoria")
  def region_to_string(:western_australia), do: gettext("Western Australia")
  def region_to_string(:south_australia), do: gettext("South Australia")
  def region_to_string(:tasmania), do: gettext("Tasmania")
  def region_to_string(unexpected_region), do: Atom.to_string(unexpected_region)

  schema "sign_regions" do
    belongs_to :sign, Signbank.Dictionary.Sign

    field :region, Ecto.Enum, values: @regions

    timestamps type: :utc_datetime
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
