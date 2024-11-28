defmodule SignbankWeb.Search.SearchForm do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many :filters, Filter, on_replace: :delete do
      field :field, Ecto.Enum, values: Signbank.Dictionary.Sign.__schema__(:fields)

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
    fields = [:field, :op, :value]

    changeset =
      filter
      |> cast(params, fields)
      |> validate_required(fields)

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
    |> IO.inspect()
  end
end
