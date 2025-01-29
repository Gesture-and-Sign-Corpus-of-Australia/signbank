defmodule SignbankWeb.SignLive.Search do
  use SignbankWeb, :live_view

  alias Signbank.Dictionary
  alias SignbankWeb.Search.SearchForm

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  # TODO: generate filters from a static config object instead of schema introspection
  def filter(assigns) do
    assigns =
      assign(assigns, :deleted, Phoenix.HTML.Form.input_value(assigns.f_filter, :delete) == true)

    ~H"""
    <div :if={!@deleted} class="field has-addons">
      <div class="control">
        <div class="select">
          <select class="input" name={@f_filter[:field].name}>
            <option value="">Pick a field</option>
            {Phoenix.HTML.Form.options_for_select(@fields, @f_filter[:field].value)}
          </select>
        </div>
      </div>
      <%!--<div class="control">
        <%!-- operator --%
      </div>
      <div class="control">
        <%!-- value --%
      </div>--%>
      <.filter_controls f_filter={@f_filter} />
      <div :if={!@last_filter} class="control">
        <.button type="button" phx-click="delete-filter" phx-value-index={@f_filter.index}>
          Delete
        </.button>
      </div>
    </div>
    """
  end

  defp filter_control(%{type: "text"} = assigns) do
    ~H"""
    <div class="control">
      <input type="text" class="input" name={@field.name} value={@field.value} />
    </div>
    """
  end

  defp filter_control(%{type: "select"} = assigns) do
    ~H"""
    <div class="control">
      <div class="select">
        <select class="input" name={@field.name}>
          <option value=""></option>
          {Phoenix.HTML.Form.options_for_select(@options, @field.value)}
        </select>
      </div>
    </div>
    """
  end

  defp filter_control(%{type: "static"} = assigns) do
    ~H"""
    <input type="hidden" name={@field.name} value={@value} />
    <div class="control">
      <a class="button is-static">
        {@display}
      </a>
    </div>
    """
  end

  defp filter_controls(assigns) do
    field = assigns.f_filter[:field].value

    if is_nil(field) do
      ~H"""
      <%!-- Don't show any filters yet --%>
      """
    else
      case Signbank.Dictionary.Sign.__schema__(:type, field) do
        :string ->
          ~H"""
          <.filter_control
            type="select"
            field={@f_filter[:op]}
            options={[
              is: :equal_to,
              contains: :contains,
              "starts with": :starts_with,
              regex: :regex
            ]}
          />
          <.filter_control type="text" field={@f_filter[:value]} />
          """

        :boolean ->
          ~H"""
          <.filter_control type="static" field={@f_filter[:op]} value={:equal_to} display="=" />
          <.filter_control
            type="select"
            field={@f_filter[:value]}
            options={[unspecified: :unspecified, false: false, true: true]}
          />
          """

        {:parameterized,
         {Ecto.Enum,
          %{
            mappings: values
          }}} ->
          assigns = assign(assigns, values: values)

          # HACK: this is ugly but its the quickest way

          ~H"""
          <.filter_control type="static" field={@f_filter[:op]} value={:equal_to} display="=" />
          <.filter_control
            type="select"
            field={@f_filter[:value]}
            options={[unspecified: :unspecified] ++ @values}
          />
          """

        {:parameterized,
         {Ecto.Embedded,
          %Ecto.Embedded{
            field: :phonology
          }}} ->
          assigns = assign(
            assigns,
            options: phonology_filters()
            |> Enum.map(fn
              %{label: label, name: name} -> {label, name}
            end)
          )
          ~H"""
          <.phonology_filter_control f_filter={@f_filter} options={@options} />
          """

        nil ->
          ~H"""
          """
      end
    end
  end

  attr  :f_filter, :map, required: true
  attr :options, :list
  attr :depth, :integer, default: 0
  # attr  :type, :atom, required: true, values: [:category, :field]
  def phonology_filter_control(assigns) do
    if assigns.f_filter[:selected] do
      assigns = assign(assigns,
      suboptions: phonology_filters(assigns.f_filter[:selected_top_level].value))
      ~H"""
      <.filter_control type="select" field={@f_filter[:selected_top_level]} options={@options} />
      <%= @suboptions %>
      """
    else
      ~H"""
      <.filter_control type="select" field={@f_filter[:selected_top_level]} options={@options} />
      """
    end
  end

  def old_phonology_filter_control(assigns) do
    top_level =
      phonology_filters()

    sub_fields =
      if assigns.f_filter[:selected_top_level].value do
        category = assigns.f_filter[:selected_top_level].value |> String.to_existing_atom()

        case Enum.find(top_level, fn x -> x.name == category end) do
          %SearchForm.FilterCategory{fields: fields} -> fields
          _ -> []
        end
      else
        []
      end

    # TODO: this part is broken with the new changes
    # TODO: handle `type: text` fields
    values = []
    # values = if assigns.f_filter[:sub_field].value do
    #   sub_field = assigns.f_filter[:sub_field].value |> String.to_existing_atom()
    #   elem(Keyword.get(sub_fields,  sub_field), 1)
    # else
    #   []
    # end
    selected = assigns.f_filter[:selected_top_level].value

    # TODO: if selected_top_level is a SearchForm.FilterCategory then we need to render one extra select
    # :field is phonology, sub_field is either the selected_top_level (if SearchForm.FilterField) or the sub_field select (if selected_top_level == SearchForm.FilterCategory)
    assigns =
      assign(assigns,
        top_level:
          top_level
          |> Enum.map(fn
            %{label: label, name: name} -> {label, name}
          end),
        sub_fields: sub_fields |> Enum.map(fn %SearchForm.FilterField{label: label, name: name} -> {label, name} end),
        values: values
      )

    ~H"""
    <.filter_control type="select" field={@f_filter[:selected_top_level]} options={@top_level} />
    <.filter_control :if={@f_filter[:selected_top_level].value != nil} type="select" field={@f_filter[:sub_field]} options={@sub_fields} />
    <.filter_control :if={@f_filter[:sub_field].value != nil} type="select" field={@f_filter[:sub_field]} options={@sub_fields} />
    <%!-- <.subfilter f_filter={@f_filter} /> --%>
    """

    # ~H"""
    #   <.filter_control type="select" field={@f_filter[:category]} options={@categories} />
    #   <%= if @f_filter[:category].value do %>
    #     <.filter_control type="select" field={@f_filter[:sub_field]} options={@sub_fields} />
    #   <% end %>
    #   <%= if @f_filter[:sub_field].value do %>
    #     <.filter_control type="static" field={@f_filter[:op]} value={:equal_to} display="=" />
    #     <.filter_control type="select" field={@f_filter[:value]} options={@values} />
    #   <% end %>
    # """
  end

  defp subfilter(assigns) do
    # if a SearchForm.FilterField, then just render op and value
    # if a SearchForm.FilterCategory then render
    # if assigns.f_filter[:category].value do
    phonology_filters(assigns.f_filter[:category].value)

    ~H"""
    <div>something</div>
    """

    # end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container is-max-desktop">
      <.simple_form id={@id} for={@form} phx-change="validate" phx-submit="search">
        <fieldset class="flex flex-col gap-2">
          <legend>Advanced search</legend>
          <.inputs_for :let={f_filter} field={@form[:filters]}>
            <.filter
              fields={@fields}
              last_filter={Enum.count(@form[:filters].value) == 1}
              f_filter={f_filter}
            />
          </.inputs_for>
          <.button type="button" phx-click="add-filter">
            {gettext("Add filter")}
          </.button>
        </fieldset>

        <:actions>
          <.button>Search</.button>
        </:actions>
      </.simple_form>

      <%= if @page && Enum.count(@page.entries) > 0 do %>
        <.table
          id="results"
          rows={@page.entries}
          row_click={fn sign -> JS.navigate(~p"/dictionary/sign/#{sign.id_gloss}") end}
        >
          <:col :let={sign} label="ID gloss">{sign.id_gloss}</:col>
          <:col :let={sign} label="Annotation ID gloss">{sign.id_gloss_annotation}</:col>
        </.table>

        <nav class="pagination" role="navigation" aria-label="pagination">
          <ul class="pagination-list">
            <%= if @page.page_number-2 > 1 do %>
              <li>
                <a phx-click="page" phx-value-num={1} class="pagination-link" aria-label="Goto page 1">
                  {1}
                </a>
              </li>
              <li>
                <span class="pagination-ellipsis">&hellip;</span>
              </li>
            <% end %>
            <%= for page_number <- (@page.page_number-2)..(@page.page_number+2) do %>
              <li :if={page_number > 0 and page_number <= @page.total_pages}>
                <a
                  phx-click="page"
                  phx-value-num={page_number}
                  class={["pagination-link", if(page_number == @page.page_number, do: "is-current")]}
                  aria-label={"Goto page #{page_number}"}
                >
                  {page_number}
                </a>
              </li>
            <% end %>
            <%= if  @page.page_number+2 < @page.total_pages do %>
              <li>
                <span class="pagination-ellipsis">&hellip;</span>
              </li>
              <li>
                <a
                  phx-click="page"
                  phx-value-num={@page.total_pages}
                  class="pagination-link"
                  aria-label={"Goto last page (#{@page.total_pages})"}
                >
                  {@page.total_pages}
                </a>
              </li>
            <% end %>
          </ul>
        </nav>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    # page =
    #   Dictionary.list_signs(socket.assigns.current_user, 1, %SignbankWeb.Search.SearchForm{
    #     filters: [%{field: "nil"}]
    #   })

    {:ok,
     socket
     |> init_filters()
     |> assign(page_title: gettext("Search signs"))
     |> assign(page: nil)}
  end

  @impl true
  def handle_event("search", %{"search_form" => params}, socket) do
    {:noreply, search(socket, params)}
  end

  @impl true
  def handle_event("validate", %{"search_form" => params}, socket) do
    changeset =
      socket.assigns.base
      |> SearchForm.changeset(params)
      |> struct!(action: :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("add-filter", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_embed(changeset, :filters)
        changeset = Ecto.Changeset.put_embed(changeset, :filters, existing ++ [%{}])
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("delete-filter", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_embed(changeset, :filters)
        {to_delete, rest} = List.pop_at(existing, index)

        filters =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        changeset
        |> Ecto.Changeset.put_embed(:filters, filters)
        |> to_form()
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("page", %{"num" => page_number}, socket) do
    {:noreply, socket |> search(socket.assigns.form.params, page_number)}
  end

  def search(socket, form, page_number \\ 1) do
    changeset = SearchForm.changeset(%SearchForm{}, form)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, data} ->
        page = Dictionary.list_signs(socket.assigns.current_user, page_number, data)
        socket |> assign(page: page)

      {:error, changeset} ->
        socket
        |> assign(form: to_form(changeset))
    end
  end

  defp init_filters(socket) do
    base = %SearchForm{
      filters: [%SearchForm.Filter{}]
    }

    changeset = SearchForm.changeset(base, %{})

    filterable_fields =
      [
        # TODO: add *all* fields, just sort whole list alphabetically
        # TODO: use optgroups
        type: gettext("Type"),
        id_gloss: gettext("ID gloss"),
        phonology: gettext("Phonology"),
        published: gettext("Published"),
        crude: gettext("Crude"),
        popular_explanation: gettext("Popular explanation"),
        is_asl_loan: gettext("Is ASL loan"),
        is_bsl_loan: gettext("Is BSL loan"),
        asl_gloss: gettext("ASL gloss"),
        bsl_gloss: gettext("BSL gloss"),
        iconicity: gettext("Iconicity"),
        signed_english_gloss: gettext("Signed English gloss"),
        is_signed_english_only: gettext("Is Signed English only"),
        is_signed_english_based_on_auslan: gettext("Is Signed English based on Auslan"),
        editorial_doubtful_or_unsure: gettext("Doubtful or unsure"),
        editorial_problematic: gettext("Problematic"),
        editorial_problematic_video: gettext("Problematic video"),
        lexis_marginal_or_minority: gettext("Marginal or minority"),
        lexis_obsolete: gettext("Obsolete"),
        lexis_technical_or_specialist_jargon: gettext("Technical or specialist jargon")
      ]
      |> Enum.map(fn {k, v} -> {v, k} end)

    assign(socket,
      fields: filterable_fields,
      base: base,
      form: to_form(changeset),
      id: "form-#{System.unique_integer()}"
    )
  end

  def boolean_options do
    [
      {gettext("Unspecified"), :unspecified},
      {gettext("False"), false},
      {gettext("True"), true}
    ]
  end

  def to_options(field_list) do
    field_list |> Enum.map(fn {k, v} -> {v, k} end)
  end

  def phonology_filters(nil) do
    nil
  end

  def phonology_filters(name) do
    Enum.find(phonology_filters(), &(Atom.to_string(&1.name) == name))
  end

  def phonology_filters do
    [
      %SearchForm.FilterField{
        name: :handedness,
        label: gettext("Handedness"),
        type: :select,
        options: Dictionary.Phonology.handednesses() |> to_options()
      },
      %SearchForm.FilterCategory{
        name: :handshape,
        label: gettext("Handshape"),
        fields: [
          %SearchForm.FilterField{
            name: :dominant_initial_handshape,
            label: gettext("Dominant initial handshape"),
            type: :select,
            options: Dictionary.Phonology.handshapes() |> to_options()
          },
          %SearchForm.FilterField{
            name: :dominant_initial_handshape_allophone,
            label: gettext("Dominant initial handshape allophone"),
            type: :select,
            options: Dictionary.Phonology.handshape_allophones() |> to_options()
          },
          %SearchForm.FilterField{
            name: :dominant_final_handshape,
            label: gettext("Dominant final handshape"),
            type: :select,
            options: Dictionary.Phonology.handshapes() |> to_options()
          },
          %SearchForm.FilterField{
            name: :dominant_final_handshape_allophone,
            label: gettext("Dominant final handshape allophone"),
            type: :select,
            options: Dictionary.Phonology.handshape_allophones() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_initial_handshape,
            label: gettext("Subordinate initial handshape"),
            type: :select,
            options: Dictionary.Phonology.handshapes() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_initial_handshape_allophone,
            label: gettext("Subordinate initial handshape allophone"),
            type: :select,
            options: Dictionary.Phonology.handshape_allophones() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_final_handshape,
            label: gettext("Subordinate final handshape"),
            type: :select,
            options: Dictionary.Phonology.handshapes() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_final_handshape_allophone,
            label: gettext("Subordinate final handshape allophone"),
            type: :select,
            options: Dictionary.Phonology.handshape_allophones() |> to_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :location,
        label: gettext("Location"),
        fields: [
          %SearchForm.FilterField{
            name: :movement_symmetrical,
            label: gettext("Symmetrical"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :initial_primary_location,
            label: gettext("Initial primary location"),
            type: :select,
            options: Dictionary.Phonology.locations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :final_primary_location,
            label: gettext("Final primary location"),
            type: :select,
            options: Dictionary.Phonology.locations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :location_rightside_or_leftside,
            label: gettext("Location rightside or leftside"),
            type: :select,
            options: Dictionary.Phonology.sides() |> to_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :metacarpus_orientation,
        label: gettext("Metacarpus orientation"),
        fields: [
          %SearchForm.FilterField{
            name: :dominant_initial_finger_hand_orientation,
            label: gettext("Dominant initial orientation"),
            type: :select,
            options: Dictionary.Phonology.finger_hand_orientations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :dominant_final_finger_hand_orientation,
            label: gettext("Dominant final orientation"),
            type: :select,
            options: Dictionary.Phonology.finger_hand_orientations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_initial_finger_hand_orientation,
            label: gettext("Subordinate initial orientation"),
            type: :select,
            options: Dictionary.Phonology.finger_hand_orientations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_final_finger_hand_orientation,
            label: gettext("Subordinate final orientation"),
            type: :select,
            options: Dictionary.Phonology.finger_hand_orientations() |> to_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :palm_orientation,
        label: gettext("Palm orientation"),
        fields: [
          %SearchForm.FilterField{
            name: :dominant_initial_palm_orientation,
            label: gettext("Dominant initial orientation"),
            type: :select,
            options: Dictionary.Phonology.palm_orientations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :dominant_final_palm_orientation,
            label: gettext("Dominant final orientation"),
            type: :select,
            options: Dictionary.Phonology.palm_orientations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_initial_palm_orientation,
            label: gettext("Subordinate initial orientation"),
            type: :select,
            options: Dictionary.Phonology.palm_orientations() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_final_palm_orientation,
            label: gettext("Subordinate final orientation"),
            type: :select,
            options: Dictionary.Phonology.palm_orientations() |> to_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :interact_location,
        label: gettext("Interact location"),
        fields: [
          %SearchForm.FilterField{
            name: :dominant_initial_interacting_handpart,
            label: gettext("Dominant initial interacting handpart"),
            type: :select,
            options: Dictionary.Phonology.handparts() |> to_options()
          },
          %SearchForm.FilterField{
            name: :dominant_final_interacting_handpart,
            label: gettext("Dominant final interacting handpart"),
            type: :select,
            options: Dictionary.Phonology.handparts() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_initial_interacting_handpart,
            label: gettext("Subordinate initial interacting handpart"),
            type: :select,
            options: Dictionary.Phonology.handparts() |> to_options()
          },
          %SearchForm.FilterField{
            name: :subordinate_final_interacting_handpart,
            label: gettext("Subordinate final interacting handpart"),
            type: :select,
            options: Dictionary.Phonology.handparts() |> to_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :contact,
        label: gettext("Contact"),
        fields: [
          %SearchForm.FilterField{
            name: :contact_start,
            label: gettext("Dominant initial interacting handpart"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :contact_end,
            label: gettext("Dominant initial interacting handpart"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :contact_during,
            label: gettext("Dominant initial interacting handpart"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :contact_body,
            label: gettext("Dominant initial interacting handpart"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :contact_hands,
            label: gettext("Dominant initial interacting handpart"),
            type: :select,
            options: boolean_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :changes,
        label: gettext("Changes"),
        fields: [
          %SearchForm.FilterField{
            name: :change_handshape,
            label: gettext("Handshape change"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :change_open,
            label: gettext("Open change"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :change_close,
            label: gettext("Close change"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :change_orientation,
            label: gettext("Orientation change"),
            type: :select,
            options: boolean_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :small_movements,
        label: gettext("Small movements"),
        fields: [
          %SearchForm.FilterField{
            name: :movement_repeated,
            label: gettext("Repeated"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_forearm_rotation,
            label: gettext("Forearm rotation"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_wrist_nod,
            label: gettext("Wrist nod"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_fingers_straighten,
            label: gettext("Fingers straighten"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_fingers_wiggle,
            label: gettext("Fingers wiggle"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_fingers_crumble,
            label: gettext("Fingers crumble"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_fingers_bend,
            label: gettext("Fingers bend"),
            type: :select,
            options: boolean_options()
          }
        ]
      },
      %SearchForm.FilterCategory{
        name: :large_movement,
        label: gettext("Large movements"),
        fields: [
          %SearchForm.FilterField{
            name: :movement_dominant_hand_only,
            label: gettext("Dominant hand only"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_symmetrical,
            label: gettext("Symmetrical"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_parallel,
            label: gettext("Parallel"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_alternating,
            label: gettext("Alternating"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_separating,
            label: gettext("Separating"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_approaching,
            label: gettext("Approaching"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_cross,
            label: gettext("Cross"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :movement_direction,
            label: gettext("Direction"),
            type: :select,
            options: Dictionary.Phonology.directions() |> to_options()
          },
          %SearchForm.FilterField{
            name: :movement_path,
            label: gettext("Path"),
            type: :select,
            options: Dictionary.Phonology.paths() |> to_options()
          },
          %SearchForm.FilterField{
            name: :movement_repeated,
            label: gettext("Repeated"),
            type: :select,
            options: boolean_options()
          },
          %SearchForm.FilterField{
            name: :repetition_type,
            label: gettext("Repeation type"),
            type: :select,
            options: Dictionary.Phonology.repetition_types() |> to_options()
          }
        ]
      }
    ]
  end
end
