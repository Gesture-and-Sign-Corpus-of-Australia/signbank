defmodule Signbank.Dictionary.SignVideo do
  @moduledoc """
  Represents a single video for an entry. Only one video can be the active video, which is shown to unauthenticated users.

  """

  # TODO: sort out whether %Video{} should also be used for definition videos and auslan definitions

  use Ecto.Schema
  import Ecto.Changeset

  schema "sign_videos" do
    field :url, :string

    belongs_to :sign, Signbank.Dictionary.Sign

    timestamps(type: :utc_datetime)
  end

  def changeset(video, attrs) do
    required_fields = [:url]

    video
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:url)
  end
end
