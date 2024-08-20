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
      add :proposed_new_sign, :boolean, default: false
      add :sense_number, :integer
      add :english_entry, :boolean, default: false

      add :suggested_signs_description, :text

      add :editorial_doubtful_or_unsure, :boolean, default: false
      add :editorial_problematic, :boolean, default: false
      add :editorial_problematic_video, :boolean, default: false

      add :lexis_marginal_or_minority, :boolean, default: false
      add :lexis_obsolete, :boolean, default: false
      add :lexis_technical_or_specialist_jargon, :boolean, default: false

      add :phonology, :map
      add :morphology, :map

      add :variant_of_id,
          references(:signs, on_delete: :nothing)

      add :asl_gloss, :string, null: true
      add :bsl_gloss, :string, null: true
      add :iconicity, :string
      add :popular_explanation, :string
      add :is_asl_loan, :boolean, null: true
      add :is_bsl_loan, :boolean, null: true
      add :legacy_sign_number, :integer
      add :legacy_stem_sign_number, :integer
      add :signed_english_gloss, :string, null: true
      add :is_signed_english_only, :boolean, default: false
      add :is_signed_english_based_on_auslan, :boolean, default: false

      add :school_anglican_or_state, :boolean, default: false
      add :school_catholic, :boolean, default: false

      add :crude, :boolean, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
