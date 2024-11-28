defmodule Signbank.Repo.Migrations.CreateSigns do
  use Ecto.Migration

  def change do
    create table(:signs) do
      add :id_gloss, :string
      add :type, :string
      add :id_gloss_annotation, :string
      add :id_gloss_variant_analysis, :string

      add :keywords, {:array, :string}
      add :legacy_id, :integer
      add :published, :boolean, default: false, null: false
      add :proposed_new_sign, :boolean
      add :sense_number, :integer
      add :english_entry, :boolean

      add :suggested_signs_description, :text

      add :editorial_doubtful_or_unsure, :boolean
      add :editorial_problematic, :boolean
      add :editorial_problematic_video, :boolean

      add :lexis_marginal_or_minority, :boolean
      add :lexis_obsolete, :boolean
      add :lexis_technical_or_specialist_jargon, :boolean

      add :phonology, :map
      add :morphology, :map

      add :variant_of_id,
          references(:signs, on_delete: :nothing)

      add :asl_gloss, :string
      add :bsl_gloss, :string
      add :iconicity, :string
      add :popular_explanation, :string
      add :is_asl_loan, :boolean
      add :is_bsl_loan, :boolean
      add :legacy_sign_number, :integer
      add :legacy_stem_sign_number, :integer
      add :signed_english_gloss, :string
      add :is_signed_english_only, :boolean
      add :is_signed_english_based_on_auslan, :boolean

      add :school_anglican_or_state, :boolean
      add :school_catholic, :boolean

      add :crude, :boolean

      timestamps(type: :utc_datetime)
    end
  end
end
