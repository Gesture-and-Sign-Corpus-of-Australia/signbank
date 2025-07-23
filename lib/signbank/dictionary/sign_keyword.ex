defmodule Signbank.Dictionary.SignKeyword do
  @moduledoc """
  Represents a single keyword for an entry.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "sign_keywords" do
    field :text, :string

    belongs_to :sign, Signbank.Dictionary.Sign

    timestamps type: :utc_datetime
  end

  def changeset(keyword, attrs) do
    required_fields = [:text]

    keyword
    |> cast(attrs, required_fields ++ [:sign_id])
    |> validate_required(required_fields)
  end
end
