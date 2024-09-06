defmodule Signbank.Dictionary.Sign do
  @moduledoc """
  A dictionary entry
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Signbank.Dictionary

  schema "signs" do
    field :type, Ecto.Enum, values: [:citation, :variant]
    field :id_gloss, :string
    field :id_gloss_annotation, :string
    field :id_gloss_variant_analysis, :string

    field :sense_number, :integer

    field :keywords, {:array, :string}
    field :legacy_id, :integer
    field :legacy_sign_number, :integer
    field :legacy_stem_sign_number, :integer
    field :published, :boolean, default: false
    field :proposed_new_sign, :boolean, default: false

    # TODO: uncomment this after adding %Tag{}/SignTag
    # many_to_many :tags, Dictionary.Tag, join_through: Dictionary.SignTag

    embeds_one :phonology, Dictionary.Phonology
    embeds_one :morphology, Dictionary.Morphology

    # TODO: revisit this, it's not a foreign key in the database, I don't know how bad that is
    belongs_to :active_video, Dictionary.SignVideo,
      foreign_key: :active_video_id,
      references: :id

    has_many :videos, Dictionary.SignVideo
    has_many :regions, Dictionary.SignRegion

    field :suggested_signs_description, :string
    has_many :suggested_signs, Dictionary.SuggestedSign

    # If type == :citation
    has_many :variants, Dictionary.Sign,
      foreign_key: :variant_of_id,
      references: :id

    # If type == :variant
    belongs_to :citation, Dictionary.Sign,
      foreign_key: :variant_of_id,
      references: :id

    has_many :definitions, Dictionary.Definition

    # TODO: uncomment this after adding %Relation{}
    # has_many :relations, Dictionary.Relation, foreign_key: :sign_a_id

    # This was WIP nothingness
    # many_to_many :relations, Dictionary.Sign,
    #   join_through: Dictionary.Relation,
    #   join_keys: [sign_a_id_gloss: :id_gloss, sign_b_id_gloss: :id_gloss]

    field :asl_gloss, :string
    field :bsl_gloss, :string
    field :iconicity, Ecto.Enum, values: [:opaque, :obscure, :translucent, :transparent]
    field :popular_explanation, :string
    field :is_asl_loan, :boolean
    field :is_bsl_loan, :boolean
    field :signed_english_gloss, :string
    field :is_signed_english_only, :boolean
    field :is_signed_english_based_on_auslan, :boolean

    field :english_entry, :boolean

    field :editorial_doubtful_or_unsure, :boolean
    field :editorial_problematic, :boolean
    field :editorial_problematic_video, :boolean

    field :lexis_marginal_or_minority, :boolean
    field :lexis_obsolete, :boolean
    field :lexis_technical_or_specialist_jargon, :boolean

    field :school_anglican_or_state, :boolean
    field :school_catholic, :boolean

    field :crude, :boolean

    timestamps(type: :utc_datetime)
  end

  def changeset(sign, attrs) do
    required_fields = [
      :type,
      :id_gloss,
      :id_gloss_annotation,
      :keywords,
      :published,
      :proposed_new_sign,
      :crude,
      :english_entry
    ]

    optional_fields = [
      :sense_number,
      :id_gloss_variant_analysis,
      :legacy_id,
      :legacy_sign_number,
      :legacy_stem_sign_number,
      :asl_gloss,
      :bsl_gloss,
      :iconicity,
      :popular_explanation,
      :is_asl_loan,
      :is_bsl_loan,
      :signed_english_gloss,
      :is_signed_english_only,
      :is_signed_english_based_on_auslan,
      :editorial_doubtful_or_unsure,
      :editorial_problematic,
      :lexis_marginal_or_minority,
      :lexis_obsolete,
      :lexis_technical_or_specialist_jargon,
      :school_anglican_or_state,
      :school_catholic
    ]

    sign
    |> cast(attrs, required_fields ++ optional_fields)
    |> cast_embed(:phonology)
    |> cast_embed(:morphology)
    |> validate_sign_type()
    |> validate_required(required_fields)
    |> foreign_key_constraint(:variants, name: :signs_variant_of_fkey)
    |> unique_constraint(:id_gloss)
    |> assoc_constraint(:citation)
    # |> assoc_constraint(:active_video_id)
    |> cast_assoc(:videos)
  end

  defp validate_sign_type(changeset) do
    type = get_field(changeset, :type)

    case type do
      :variant ->
        changeset
        |> guard_field_exists(:variant_of_id, "must be set when type is variant")

      # TODO: uncomment this
      # |> guard_field_not_exists(:definitions, "variant cannot have definitions")

      :citation ->
        changeset
        |> guard_field_not_exists(:variant_of_id, "cannot be set when type is not variant")

      _ ->
        changeset
    end
  end

  # These guard functions are syntactic sugar for adding errors to the changeset
  defp guard_field_exists(changeset, field, message) do
    case get_field(changeset, field) do
      nil -> add_error(changeset, field, message)
      _ -> changeset
    end
  end

  defp guard_field_not_exists(changeset, field, message) do
    case get_field(changeset, field) do
      nil -> changeset
      [] -> changeset
      _ -> add_error(changeset, field, message)
    end
  end
end
