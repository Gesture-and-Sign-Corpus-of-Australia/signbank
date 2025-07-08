defmodule SearchFilter do
  @moduledoc """
  One line of the advanced search form.
  """
  use SignbankWeb, :live_view
  alias Signbank.Dictionary

  defmodule Category do
    @moduledoc """
    Defines a field that allows the user to select from a collection
    of fields in the advanced search form.
    """
    defstruct name: nil, label: nil, fields: []
  end

  defmodule Field do
    @moduledoc """
    Defines one field in the advanced search form.
    """
    defstruct name: nil, inside: nil, label: nil, type: nil, options: nil
  end

  def control(assigns) do
    selection_resolved_to_fields =
      assigns.selection
      |> Enum.scan([], fn x, acc ->
        acc ++ [x]
      end)
      |> Enum.map(fn y ->
        Enum.reduce(
          y,
          filters(),
          fn
            x, %Category{fields: fields} ->
              Enum.find(fields, &(&1.name == x))

            _x, %Field{} = field ->
              field

            x, fields ->
              Enum.find(fields, &(&1.name == x))
          end
        )
      end)

    # pointer is a version of filter() scoped to the current selection path
    pointer =
      Enum.reduce(
        assigns.selection,
        filters(),
        fn
          x, %Category{fields: fields} ->
            Enum.find(fields, &(&1.name == x))

          _x, %Field{} = field ->
            field

          x, fields ->
            Enum.find(fields, &(&1.name == x))
        end
      )

    assigns =
      assign(assigns,
        pointer: pointer,
        fields: selection_resolved_to_fields
      )

    ~H"""
    <div class="flex gap-4">
      <.form
        class="hidden"
        id={@field_select_form_id}
        for={@field_select_form}
        phx-change="pick"
        phx-value-index={@index}
      >
      </.form>

      <.input
        type="select"
        name={:root}
        form={@field_select_form_id}
        prompt="Pick a field"
        value={List.first(@selection)}
        options={
          filters()
          |> Enum.map(fn
            %Field{label: label, name: name} -> {label, name}
            %Category{label: label, name: name} -> {label <> " →", name}
          end)
        }
      />

      <.field_select
        :for={{field, index} <- Enum.with_index(@fields, 1)}
        form={@field_select_form_id}
        index={index}
        field={field}
        search_form_id={@search_form_id}
        f_filter={@f_filter}
        search_form={@search_form}
        value={Enum.at(@selection, index)}
      />

      <div :if={@is_deletable}>
        <.button type="button" phx-click="delete-filter" phx-value-index={@f_filter.index}>
          Delete
        </.button>
      </div>
    </div>
    """
  end

  defp field_select(%{field: %Category{}} = assigns) do
    ~H"""
    <.input
      type="select"
      name={@index}
      prompt="Pick a field"
      value={@value}
      form={@form}
      options={
        @field.fields
        |> Enum.map(fn
          %Field{label: label, name: name} -> {label, name}
          %Category{label: label, name: name} -> {label <> " →", name}
        end)
      }
    />
    """
  end

  defp field_select(%{field: %Field{}} = assigns) do
    ~H"""
    <%= if @field.inside do %>
      <.input type="hidden" form={@search_form_id} field={@f_filter[:field]} value={@field.inside} />
      <.input type="hidden" form={@search_form_id} field={@f_filter[:sub_field]} value={@field.name} />
    <% else %>
      <.input type="hidden" form={@search_form_id} field={@f_filter[:field]} value={@field.name} />
    <% end %>
    <.filter_input
      field={@field}
      search_form_id={@search_form_id}
      form={@search_form}
      f_filter={@f_filter}
    />
    """
  end

  defp field_select(%{field: nil} = assigns) do
    ~H"""
    <div>
      something went wrong
    </div>
    """
  end

  defp filter_input(%{field: %Field{type: "boolean"}} = assigns) do
    ~H"""
    [ = ] <.input type="hidden" form={@search_form_id} field={@f_filter[:op]} value={:equal_to} />
    <.input
      type="select"
      prompt="Pick a value"
      form={@search_form_id}
      field={@f_filter[:value]}
      options={[
        Unspecified: :unspecified,
        False: false,
        True: true
      ]}
    />
    """
  end

  defp filter_input(%{field: %Field{type: "select"}} = assigns) do
    ~H"""
    [ = ] <.input type="hidden" form={@search_form_id} field={@f_filter[:op]} value={:equal_to} />
    <.input
      type="select"
      prompt="Pick a value"
      form={@search_form_id}
      field={@f_filter[:value]}
      options={@field.options}
    />
    """
  end

  defp filter_input(%{field: %Field{type: "text"}} = assigns) do
    ~H"""
    <.input
      type="select"
      prompt="Pick a value"
      form={@search_form_id}
      field={@f_filter[:op]}
      options={[
        is: :equal_to,
        contains: :contains,
        "starts with": :starts_with,
        regex: :regex
      ]}
    />
    <.input
      type="text"
      prompt="Pick a value"
      form={@search_form_id}
      field={@f_filter[:value]}
      options={@field.options}
    />
    """
  end

  defp filter_input(%{field: %Field{type: "number"}} = assigns) do
    ~H"""
    <.input
      type="select"
      prompt="Pick a value"
      form={@search_form_id}
      field={@f_filter[:op]}
      options={[
        >: :greater_than,
        =: :equal_to,
        <: :less_than
      ]}
    />
    <.input type="number" form={@search_form_id} field={@f_filter[:value]} />
    """
  end

  defp filter_input(assigns) do
    ~H"""
    Field type not configured
    """
  end

  # TODO: possibly add filters on variants
  defp filters do
    [
      # Missing fields:
      #   regions (really wants a multi select) (possibly with "any of" "all of" and "none of"(??))
      #   relations
      #   videos (needs "has video")
      #   regions
      %Field{
        label: "Type",
        name: :type,
        type: "select",
        options: [Citation: "citation", Variant: "variant"]
      },
      %Field{label: "ID gloss", name: :id_gloss, type: "text"},
      %Field{label: "Annotation ID gloss", name: :id_gloss_annotation, type: "text"},
      %Field{label: "Variant analysis", name: :id_gloss_variant_analysis, type: "text"},
      # TODO: look at his; we don't have a number field type yet
      %Field{label: "Sense number", name: :sense_number, type: "number"},

      # TODO: only show these to editors
      # %Field{label: "legacy_id", name: :legacy_id, type: "text"},
      # %Field{label: "legacy_sign_number", name: :legacy_sign_number, type: "text"},
      # %Field{label: "legacy_stem_sign_number", name: :legacy_stem_sign_number, type: "text"},

      # TODO: tricky one, this is actually an array
      %Field{label: "Keywords", name: :keywords, type: "text"},

      # TODO: only show to editors
      %Field{label: "Published", name: :published, type: "boolean"},
      %Field{label: "Proposed new sign", name: :proposed_new_sign, type: "boolean"},
      %Field{label: "Crude", name: :crude, type: "boolean"},

      # TODO: have way to search relations (shouldn't be nested; that gets messy, although
      # it could be fun), we need things like "has no related videos" and "has at least one synonym"

      %Field{label: "Anglican or state school", name: :school_anglican_or_state, type: "boolean"},
      %Field{label: "Catholic school", name: :school_catholic, type: "boolean"},
      %Field{label: "ASL gloss", name: :asl_gloss, type: "text"},
      %Field{label: "BSL gloss", name: :bsl_gloss, type: "text"},

      # TODO: not sure where to put this in the order
      %Field{
        label: "Suggested signs description",
        name: :suggested_signs_description,
        type: "text"
      },

      # TODO: not sure where to put this in the order
      %Field{
        label: "Suggested signs description",
        name: :suggested_signs_description,
        type: "text"
      },
      # TODO: these fields don't exist yet, but this is their filter definition for when they do
      # %Field{label: "Note", name: :note, type: "text"},
      # %Field{label: "Editor note", name: :editor_note, type: "text"},

      %Field{
        label: "Iconicity",
        name: :iconicity,
        type: "select",
        options: Dictionary.Sign.iconicity_values()
      },
      %Field{label: "Popular explanation", name: :popular_explanation, type: "text"},
      %Field{label: "Is ASL loan", name: :is_asl_loan, type: "boolean"},
      %Field{label: "Is BSL loan", name: :is_bsl_loan, type: "boolean"},
      %Field{label: "Signed English gloss", name: :signed_english_gloss, type: "text"},
      %Field{label: "Is Signed English only", name: :is_signed_english_only, type: "boolean"},
      %Field{
        label: "Is Signed English based on Auslan",
        name: :is_signed_english_based_on_auslan,
        type: "boolean"
      },
      %Field{label: "English entry", name: :english_entry, type: "boolean"},
      %Category{
        name: :editorial,
        label: gettext("Editorial"),
        fields: [
          %Field{
            label: "Doubtful or unsure",
            name: :editorial_doubtful_or_unsure,
            type: "boolean"
          },
          %Field{label: "Problematic", name: :editorial_problematic, type: "boolean"},
          %Field{
            label: "Problematic video",
            name: :editorial_problematic_video,
            type: "boolean"
          }
        ]
      },
      %Category{
        name: :lexis,
        label: gettext("Lexis"),
        fields: [
          %Field{
            label: "Marginal or minority",
            name: :lexis_marginal_or_minority,
            type: "boolean"
          },
          %Field{label: "Obsolete", name: :lexis_obsolete, type: "boolean"},
          %Field{
            label: "Technical or specialist jargon",
            name: :lexis_technical_or_specialist_jargon,
            type: "boolean"
          }
        ]
      },
      %Category{
        name: :phonology,
        label: gettext("Phonology"),
        fields: phonology_fields()
      },
      %Category{
        name: :morphology,
        label: gettext("Morphology"),
        fields: morphology_fields()
      }
    ]
  end

  defp phonology_fields do
    [
      %Category{
        name: :dominant,
        label: gettext("Dominant"),
        fields: [
          %Category{
            name: :initial,
            label: gettext("Initial"),
            fields: [
              %Field{
                label: "Initial handshape",
                inside: :phonology,
                type: "select",
                name: :dominant_initial_handshape,
                options: Dictionary.Phonology.handshapes()
              },
              %Field{
                label: "Initial handshape allophone",
                inside: :phonology,
                type: "select",
                name: :dominant_initial_handshape_allophone,
                options: Dictionary.Phonology.handshape_allophones()
              },
              %Field{
                label: "Initial interacting handpart",
                inside: :phonology,
                type: "select",
                name: :dominant_initial_interacting_handpart,
                options: Dictionary.Phonology.handparts()
              },
              %Field{
                label: "Initial finger-hand orientation",
                inside: :phonology,
                type: "select",
                name: :dominant_initial_finger_hand_orientation,
                options: Dictionary.Phonology.finger_hand_orientations()
              },
              %Field{
                label: "Initial palm orientation",
                inside: :phonology,
                type: "select",
                name: :dominant_initial_palm_orientation,
                options: Dictionary.Phonology.palm_orientations()
              }
            ]
          },
          %Category{
            name: :final,
            label: gettext("Final"),
            fields: [
              %Field{
                label: "Final handshape",
                inside: :phonology,
                type: "select",
                name: :dominant_final_handshape,
                options: Dictionary.Phonology.handshapes()
              },
              %Field{
                label: "Final handshape allophone",
                inside: :phonology,
                type: "select",
                name: :dominant_final_handshape_allophone,
                options: Dictionary.Phonology.handshape_allophones()
              },
              %Field{
                label: "Final interacting handpart",
                inside: :phonology,
                type: "select",
                name: :dominant_final_interacting_handpart,
                options: Dictionary.Phonology.handparts()
              },
              %Field{
                label: "Final finger-hand orientation",
                inside: :phonology,
                type: "select",
                name: :dominant_final_finger_hand_orientation,
                options: Dictionary.Phonology.finger_hand_orientations()
              },
              %Field{
                label: "Final palm orientation",
                inside: :phonology,
                type: "select",
                name: :dominant_final_palm_orientation,
                options: Dictionary.Phonology.palm_orientations()
              }
            ]
          }
        ]
      },
      %Category{
        name: :subordinate,
        label: gettext("Subordinate"),
        fields: [
          %Category{
            name: :initial,
            label: gettext("Initial"),
            fields: [
              %Field{
                label: "Initial handshape",
                inside: :phonology,
                type: "select",
                name: :subordinate_initial_handshape,
                options: Dictionary.Phonology.handshapes()
              },
              %Field{
                label: "Initial handshape allophone",
                inside: :phonology,
                type: "select",
                name: :subordinate_initial_handshape_allophone,
                options: Dictionary.Phonology.handshape_allophones()
              },
              %Field{
                label: "Initial interacting handpart",
                inside: :phonology,
                type: "select",
                name: :subordinate_initial_interacting_handpart,
                options: Dictionary.Phonology.handparts()
              },
              %Field{
                label: "Initial finger-hand orientation",
                inside: :phonology,
                type: "select",
                name: :subordinate_initial_finger_hand_orientation,
                options: Dictionary.Phonology.finger_hand_orientations()
              },
              %Field{
                label: "Initial palm orientation",
                inside: :phonology,
                type: "select",
                name: :subordinate_initial_palm_orientation,
                options: Dictionary.Phonology.palm_orientations()
              }
            ]
          },
          %Category{
            name: :final,
            label: gettext("Final"),
            fields: [
              %Field{
                label: "Final handshape",
                inside: :phonology,
                type: "select",
                name: :subordinate_final_handshape,
                options: Dictionary.Phonology.handshapes()
              },
              %Field{
                label: "Final handshape allophone",
                inside: :phonology,
                type: "select",
                name: :subordinate_final_handshape_allophone,
                options: Dictionary.Phonology.handshape_allophones()
              },
              %Field{
                label: "Final interacting handpart",
                inside: :phonology,
                type: "select",
                name: :subordinate_final_interacting_handpart,
                options: Dictionary.Phonology.handparts()
              },
              %Field{
                label: "Final finger-hand orientation",
                inside: :phonology,
                type: "select",
                name: :subordinate_final_finger_hand_orientation,
                options: Dictionary.Phonology.finger_hand_orientations()
              },
              %Field{
                label: "Final palm orientation",
                inside: :phonology,
                type: "select",
                name: :subordinate_final_palm_orientation,
                options: Dictionary.Phonology.palm_orientations()
              }
            ]
          }
        ]
      },
      # dominant_initial_handshape, Ecto.Enum, values: @handshapes
      # dominant_initial_handshape_allophone, Ecto.Enum, values: @handshape_allophones
      # dominant_final_handshape, Ecto.Enum, values: @handshapes
      # dominant_final_handshape_allophone, Ecto.Enum, values: @handshape_allophones
      # dominant_initial_interacting_handpart, Ecto.Enum, values: @handparts
      # dominant_final_interacting_handpart, Ecto.Enum, values: @handparts
      # dominant_initial_finger_hand_orientation, Ecto.Enum, values: @finger_hand_orientations
      # dominant_final_finger_hand_orientation, Ecto.Enum, values: @finger_hand_orientations
      # dominant_initial_palm_orientation, Ecto.Enum, values: @palm_orientations
      # dominant_final_palm_orientation, Ecto.Enum, values: @palm_orientations
      # subordinate_initial_handshape, Ecto.Enum, values: @handshapes
      # subordinate_initial_handshape_allophone, Ecto.Enum, values: @handshape_allophones
      # subordinate_final_handshape, Ecto.Enum, values: @handshapes
      # subordinate_final_handshape_allophone, Ecto.Enum, values: @handshape_allophones
      # subordinate_initial_interacting_handpart, Ecto.Enum, values: @handparts
      # subordinate_final_interacting_handpart, Ecto.Enum, values: @handparts
      # subordinate_initial_finger_hand_orientation, Ecto.Enum,
      # subordinate_final_finger_hand_orientation, Ecto.Enum, values: @finger_hand_orientations
      # subordinate_initial_palm_orientation, Ecto.Enum, values: @palm_orientations
      # subordinate_final_palm_orientation, Ecto.Enum, values: @palm_orientations

      %Category{
        name: :primary_location,
        label: gettext("Primary location"),
        fields: [
          %Field{
            label: "Initial",
            type: "select",
            name: :initial_primary_location,
            options: Dictionary.Phonology.locations()
          },
          %Field{
            label: "Final",
            inside: :phonology,
            type: "select",
            name: :final_primary_location,
            options: Dictionary.Phonology.locations()
          }
        ]
      },
      %Field{
        label: "Rightside or leftside",
        type: "select",
        name: :location_rightside_or_leftside,
        inside: :phonology,
        options: Dictionary.Phonology.sides()
      },
      %Category{
        name: :movement,
        label: gettext("Movement"),
        fields: [
          %Field{
            label: "movement_dominant_hand_only",
            name: :movement_dominant_hand_only,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_symmetrical",
            name: :movement_symmetrical,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_parallel",
            name: :movement_parallel,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_alternating",
            name: :movement_alternating,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_separating",
            name: :movement_separating,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_approaching",
            name: :movement_approaching,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_cross",
            name: :movement_cross,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_direction",
            name: :movement_direction,
            inside: :phonology,
            type: "select",
            options: Dictionary.Phonology.directions()
          },
          %Field{
            label: "movement_path",
            name: :movement_path,
            inside: :phonology,
            type: "select",
            options: Dictionary.Phonology.paths()
          },
          %Field{
            label: "movement_repeated",
            name: :movement_repeated,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_forearm_rotation",
            name: :movement_forearm_rotation,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_wrist_nod",
            name: :movement_wrist_nod,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_fingers_straighten",
            name: :movement_fingers_straighten,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_fingers_wiggle",
            name: :movement_fingers_wiggle,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_fingers_crumble",
            name: :movement_fingers_crumble,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "movement_fingers_bend",
            name: :movement_fingers_bend,
            inside: :phonology,
            type: "boolean"
          }
        ]
      },
      %Category{
        name: :change,
        label: gettext("Change"),
        fields: [
          %Field{
            label: "Handshape",
            name: :change_handshape,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "Open",
            name: :change_open,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "Close",
            name: :change_close,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "Orientation",
            name: :change_orientation,
            inside: :phonology,
            type: "boolean"
          }
        ]
      },
      %Category{
        name: :contact,
        label: gettext("Contact"),
        fields: [
          %Field{
            label: "Start",
            name: :contact_start,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "End",
            name: :contact_end,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "During",
            name: :contact_during,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "Body",
            name: :contact_body,
            inside: :phonology,
            type: "boolean"
          },
          %Field{
            label: "Hands",
            name: :contact_hands,
            inside: :phonology,
            type: "boolean"
          }
        ]
      },
      %Field{
        label: "HamNoSys",
        name: :hamnosys,
        inside: :phonology,
        type: "boolean"
      },
      %Field{
        label: "HamNoSys variant analysis",
        name: :hamnosys_variant_analysis,
        inside: :phonology,
        type: "boolean"
      },
      %Field{
        label: "Handedness",
        name: :handedness,
        inside: :phonology,
        type: "select",
        options: Dictionary.Phonology.handednesses()
      },
      %Field{
        label: "Repetition type",
        name: :repetition_type,
        inside: :phonology,
        type: "select",
        options: Dictionary.Phonology.repetition_types()
      }
    ]
  end

  defp morphology_fields do
    [
      %Field{label: "Directional", inside: :morphology, name: :directional, type: "boolean"},
      %Field{
        label: "Beginning directional",
        inside: :morphology,
        name: :beginning_directional,
        type: "boolean"
      },
      %Field{
        label: "End directional",
        inside: :morphology,
        name: :end_directional,
        type: "boolean"
      },
      %Field{label: "Orientating", inside: :morphology, name: :orientating, type: "boolean"},
      %Field{label: "Body locating", inside: :morphology, name: :body_locating, type: "boolean"},
      %Field{label: "Is initialism", inside: :morphology, name: :is_initialism, type: "boolean"},
      %Field{label: "Is alphabet", inside: :morphology, name: :is_alphabet, type: "boolean"},
      %Field{
        label: "Is abbreviation",
        inside: :morphology,
        name: :is_abbreviation,
        type: "boolean"
      },
      %Field{
        label: "Is fingerspelled word",
        inside: :morphology,
        name: :is_fingerspelled_word,
        type: "boolean"
      },
      %Field{label: "Blend of", inside: :morphology, name: :blend_of, type: "text"},
      %Field{label: "Calque of", inside: :morphology, name: :calque_of, type: "text"},
      %Field{label: "Compound of", inside: :morphology, name: :compound_of, type: "text"},
      %Field{label: "Idiom of", inside: :morphology, name: :idiom_of, type: "text"},
      %Field{
        label: "Initialization of",
        inside: :morphology,
        name: :initialization_of,
        type: "text"
      },
      %Field{
        label: "Multi sign expression",
        inside: :morphology,
        name: :multi_sign_expression,
        type: "text"
      }
    ]
  end
end
