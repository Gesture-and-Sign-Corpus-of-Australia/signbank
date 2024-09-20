defmodule SignbankWeb.SignLive.Search do
  use SignbankWeb, :live_view

  alias Signbank.Dictionary
  alias SignbankWeb.Search.SearchForm

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  def filter(assigns) do
    assigns =
      assign(assigns, :deleted, Phoenix.HTML.Form.input_value(assigns.f_filter, :delete) == true)

    ~H"""
    <div :if={!@deleted} class="field has-addons">
      <div class="control">
        <div class="select">
          <select class="input" name={@f_filter[:field].name}>
            <option value="">Pick a field</option>
            <%= Phoenix.HTML.Form.options_for_select(@fields, @f_filter[:field].value) %>
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
          <%= Phoenix.HTML.Form.options_for_select(@options, @field.value) %>
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
        <%= @display %>
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
          <.filter_control type="select" field={@f_filter[:value]} options={[false, true]} />
          """

        {:parameterized, Ecto.Enum,
         %{
           mappings: values
         }} ->
          assigns = assign(assigns, values: values)

          ~H"""
          <.filter_control type="static" field={@f_filter[:op]} value={:equal_to} display="=" />
          <.filter_control type="select" field={@f_filter[:value]} options={@values} />
          """

        nil ->
          ~H"""

          """
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
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
          <%= gettext("Add filter") %>
        </.button>
      </fieldset>

      <:actions>
        <.button>Search</.button>
      </:actions>
    </.simple_form>

    <.table
      :if={Enum.count(@page.entries) > 0}
      id="results"
      rows={@page.entries}
      row_click={fn sign -> JS.navigate(~p"/dictionary/sign/#{sign.id_gloss}") end}
    >
      <:col :let={sign} label="ID gloss"><%= sign.id_gloss %></:col>
      <:col :let={sign} label="Annotation ID gloss"><%= sign.id_gloss_annotation %></:col>
    </.table>

    <nav class="pagination" role="navigation" aria-label="pagination">
      <ul class="pagination-list">
        <%= if @page.page_number-2 > 1 do %>
          <li>
            <a phx-click="page" phx-value-num={1} class="pagination-link" aria-label="Goto page 1">
              <%= 1 %>
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
              <%= page_number %>
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
              <%= @page.total_pages %>
            </a>
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end

  @impl true
  def mount(_, _, socket) do
    page = Dictionary.list_signs(socket.assigns.current_user)

    {:ok,
     socket
     |> init_filters()
     |> assign(page_title: gettext("Search signs"))
     |> assign(page: page)}
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

    filterable_fields = [
      :type,
      :id_gloss,
      :published,
      :crude,
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
      :editorial_problematic_video,
      :lexis_marginal_or_minority,
      :lexis_obsolete,
      :lexis_technical_or_specialist_jargon
    ]

    assign(socket,
      fields: filterable_fields,
      base: base,
      form: to_form(changeset),
      id: "form-#{System.unique_integer()}"
    )
  end
end
