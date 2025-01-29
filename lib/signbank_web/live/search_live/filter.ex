defmodule SignbankWeb.Search.SearchForm do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many :filters, Filter, on_replace: :delete do
      field :field, Ecto.Enum, values: Signbank.Dictionary.Sign.__schema__(:fields)
      # sub_field is a key on :field, for filtering on nested data
      field :sub_field, :string, default: nil

      field :op, Ecto.Enum,
        values: [
          :greater_than,
          :less_than,
          :equal_to,
          :contains,
          :starts_with,
          :regex
        ]

      field :value, :string, default: nil
      field :delete, :boolean, virtual: true
    end
  end

  @doc false
  def changeset(form, params) do
    form
    |> cast(params, [])
    |> cast_embed(:filters,
      with: &filter_changeset/2
    )
  end

  @doc false
  def filter_changeset(filter, params) do
    changeset =
      filter
      |> cast(params, [:field, :op, :sub_field, :value])
      |> validate_required([:field, :op, :value])

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end

defmodule SignbankWeb.Search.SearchForm.FilterCategory do
  defstruct name: nil, label: nil, fields: []
end

defmodule SignbankWeb.Search.SearchForm.FilterField do
  defstruct name: nil, label: nil, type: nil, options: nil
end
