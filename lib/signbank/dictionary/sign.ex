defmodule Signbank.Dictionary.Sign do
  @moduledoc """
  A dictionary entry
  """
  use Ecto.Schema
  use Gettext, backend: Signbank.Gettext
  import Ecto.Changeset
  alias Signbank.Dictionary

  @iconicity_values [
    opaque: gettext("opaque"),
    obscure: gettext("obscure"),
    translucent: gettext("translucent"),
    transparent: gettext("transparent")
  ]
  def iconicity_values, do: reverse(@iconicity_values)

  defp reverse(keywords) do
    Enum.map(keywords, fn {k, v} -> {v, k} end)
  end

  schema "signs" do
    field :type, Ecto.Enum, values: [:citation, :variant]
    field :id_gloss, :string
    field :id_gloss_annotation, :string
    field :id_gloss_variant_analysis, :string

    field :sense_number, :integer

    has_many :keywords, Dictionary.SignKeyword, on_replace: :delete
    field :legacy_id, :integer
    field :legacy_sign_number, :integer
    field :legacy_stem_sign_number, :integer
    field :published, :boolean, default: false
    field :proposed_new_sign, :boolean, default: false

    # TODO: uncomment this after adding %Tag{}/SignTag
    # many_to_many :tags, Dictionary.Tag, join_through: Dictionary.SignTag

    embeds_one :phonology, Dictionary.Phonology, on_replace: :update
    embeds_one :morphology, Dictionary.Morphology, on_replace: :update

    # TODO: revisit this, it's not a foreign key in the database, I don't know how bad that is
    belongs_to :active_video, Dictionary.SignVideo,
      foreign_key: :active_video_id,
      references: :id,
      on_replace: :nilify

    has_many :videos, Dictionary.SignVideo, on_replace: :delete
    has_many :regions, Dictionary.SignRegion, on_replace: :delete

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

    has_many :definitions, Dictionary.Definition,
      preload_order: [asc: :pos],
      on_replace: :delete

    # TODO: uncomment this after adding %Relation{}
    has_many :relations, Dictionary.SignRelation, foreign_key: :sign_a_id

    # This was WIP nothingness
    # many_to_many :relations, Dictionary.Sign,
    #   join_through: Dictionary.Relation,
    #   join_keys: [sign_a_id_gloss: :id_gloss, sign_b_id_gloss: :id_gloss]

    field :asl_gloss, :string
    field :bsl_gloss, :string
    field :iconicity, Ecto.Enum, values: @iconicity_values
    field :popular_explanation, :string
    # TODO: add these note fields
    # field :augment_note, :string
    # field :note, :string
    # field :editor_note, :string
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

    many_to_many :semantic_categories, Dictionary.SemanticCategory,
      join_through: "signs_semantic_categories"

    timestamps type: :utc_datetime
  end

  def changeset(sign, attrs) do
    required_fields = [
      :type,
      :id_gloss,
      :id_gloss_annotation,
      :published,
      :proposed_new_sign,
      :crude
    ]

    optional_fields = [
      :sense_number,
      :id_gloss_variant_analysis,
      :legacy_id,
      :legacy_sign_number,
      :legacy_stem_sign_number,
      :suggested_signs_description,
      :asl_gloss,
      :bsl_gloss,
      :iconicity,
      :popular_explanation,
      :is_asl_loan,
      :is_bsl_loan,
      :signed_english_gloss,
      :is_signed_english_only,
      :is_signed_english_based_on_auslan,
      :english_entry,
      :editorial_doubtful_or_unsure,
      :editorial_problematic,
      :editorial_problematic_video,
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
    # |> assoc_constraint(:active_video)
    # |> put_assoc(:active_video, attrs[:active_video])
    # cast suggested_signs
    # cast semantic_categories
    |> cast_assoc(:keywords,
      with: &Dictionary.SignKeyword.changeset/2
    )
    |> cast_assoc(:active_video,
      with: &Dictionary.SignVideo.changeset/2
    )
    |> cast_assoc(
      :videos,
      with: &Dictionary.SignVideo.changeset/2,
      drop_param: :videos_drop
    )
    |> cast_assoc(
      :definitions,
      with: &Dictionary.Definition.changeset/3,
      sort_param: :definitions_position
    )
    |> put_regions(sign, attrs)
  end

  defp put_regions(changeset, sign, attrs) do
    case Map.get(attrs, "regions", []) do
      [] ->
        changeset

      regions ->
        put_assoc(
          changeset,
          :regions,
          for region <- regions do
            sign
            |> Ecto.build_assoc(:regions)
            |> Ecto.Changeset.cast(%{region: region}, [:region])
          end
        )
    end
  end

  defp match_region_names_to_existing(region_names, sign) do
    Enum.map(region_names, fn region_name ->
      # Dictionary.SignRegion.changeset(%Dictionary.SignRegion{}, %{sign_id: sign.id, region: region_name})
      new_region =
        sign
        |> Ecto.build_assoc(:regions)
        |> Ecto.Changeset.cast(%{region: region_name}, [:region])

      Enum.find(sign.regions, new_region, &(&1.region == region_name))
    end)
  end

  defp validate_sign_type(changeset) do
    type = get_field(changeset, :type)

    case type do
      :variant ->
        changeset
        |> guard_field_exists(:variant_of_id, "must be set when type is variant")
        |> guard_field_not_exists(:definitions, "variant cannot have definitions")

      :citation ->
        guard_field_not_exists(
          changeset,
          :variant_of_id,
          "cannot be set when type is not variant"
        )

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
