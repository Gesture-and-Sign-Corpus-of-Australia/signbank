defmodule Signbank.Dictionary.SuggestedSign do
  @moduledoc """
  Represents a suggestion video for an entry.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "suggested_signs" do
    field :url, :string
    field :description, :string

    belongs_to :sign, Signbank.Dictionary.Sign

    timestamps type: :utc_datetime
  end

  def changeset(video, attrs) do
    required_fields = [:url, :sign_id]

    video
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
