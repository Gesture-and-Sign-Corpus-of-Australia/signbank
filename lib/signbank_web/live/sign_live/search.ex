defmodule SignbankWeb.Search do
  @moduledoc """
  Advanced search page.
  """
  use SignbankWeb, :live_view
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @impl true
  def mount(_, _, socket) do
    base = %Signbank.Search{
      filters: [%Signbank.Search.Filter{}]
    }

    {:ok,
     assign(socket,
       base: base,
       form: to_form(Signbank.Search.changeset(base, %{})),
       filter_states: new_filter([]),
       id: "form-#{System.unique_integer()}",
       page_title: gettext("Search signs"),
       page: nil
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.inputs_for :let={f_filter} field={@form[:filters]}>
        <SearchFilter.control
          id={f_filter.id}
          index={f_filter.index}
          module={SearchFilter}
          f_filter={f_filter}
          search_form_id={@id}
          search_form={@form}
          selection={Enum.at(@filter_states, f_filter.index).selection}
          field_select_form_id={"field_select_#{f_filter.id}"}
          field_select_form={Enum.at(@filter_states, f_filter.index).form}
          is_deletable={Enum.count(@form[:filters].value) > 1}
        />
      </.inputs_for>

      <.form id={@id} for={@form} phx-change="validate" phx-submit="search">
        <.button type="button" phx-click="add-filter">
          {gettext("Add filter")}
        </.button>

        <.button>Search</.button>
      </.form>

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
          <ul class="join">
            <%= if @page.page_number-2 > 1 do %>
              <a phx-click="page" phx-value-num={1} class="btn join-item" aria-label="Goto page 1">
                {1}
              </a>
              <span class="btn btn-disabled">&hellip;</span>
            <% end %>
            <%= for page_number <- (@page.page_number-2)..(@page.page_number+2) do %>
              <a
                :if={page_number > 0 and page_number <= @page.total_pages}
                phx-click="page"
                phx-value-num={page_number}
                class={["btn join-item", if(page_number == @page.page_number, do: "bg-slate-300")]}
                aria-label={"Goto page #{page_number}"}
              >
                {page_number}
              </a>
            <% end %>
            <%= if  @page.page_number+2 < @page.total_pages do %>
              <span class="btn btn-disabled">&hellip;</span>
              <a
                phx-click="page"
                phx-value-num={@page.total_pages}
                class="btn join-item"
                aria-label={"Goto last page (#{@page.total_pages})"}
              >
                {@page.total_pages}
              </a>
            <% end %>
          </ul>
        </nav>
      <% end %>
    </Layouts.app>
    """
  end

  def search(socket, form, page_number \\ 1) do
    changeset = Signbank.Search.changeset(%Signbank.Search{}, form)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, data} ->
        page =
          Dictionary.list_signs(socket.assigns.current_scope, page_number, data)

        assign(socket, page: page)

      {:error, changeset} ->
        assign(socket,
          form: to_form(changeset)
        )
    end
  end

  @impl true
  def handle_event("search", %{"search" => params}, socket) do
    {:noreply, search(socket, params)}
  end

  @impl true
  def handle_event("page", %{"num" => page_number}, socket) do
    {:noreply, search(socket, socket.assigns.form.params, page_number)}
  end

  @impl true
  def handle_event("add-filter", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_embed(changeset, :filters)
        changeset = Ecto.Changeset.put_embed(changeset, :filters, existing ++ [%{}])

        to_form(changeset)
      end)
      |> assign(filter_states: new_filter(socket.assigns.filter_states))

    {:noreply, socket}
  end

  def handle_event("delete-filter", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      socket
      |> update(:form, fn %{source: changeset} ->
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
      |> assign(filter_states: List.delete_at(socket.assigns.filter_states, index))

    {:noreply, socket}
  end

  def handle_event("validate", %{"search" => params}, socket) do
    changeset =
      socket.assigns.base
      |> Signbank.Search.changeset(params)
      |> struct!(action: :validate)

    # TODO: error handling

    {:noreply,
     assign(socket,
       form: to_form(changeset),
       touched: true
     )}
  end

  # TODO: there is a bug where swapping out the root selection doesn't delete the existing value, so setting
  # up a boolean filter and changing to a text one leaves the value input saying "true"
  @impl true
  def handle_event("pick", %{"_target" => [target], "index" => filter_index} = params, socket) do
    filter_index = String.to_integer(filter_index)
    v = String.to_existing_atom(params[target])
    i = if target == "root", do: 0, else: String.to_integer(target)

    new_state =
      socket.assigns.filter_states
      |> Enum.at(filter_index)
      |> Map.update!(:selection, fn selection ->
        Enum.slice(selection, 0, i) ++ [v]
      end)

    socket =
      assign(
        socket,
        :filter_states,
        List.replace_at(
          socket.assigns.filter_states,
          filter_index,
          new_state
        )
      )

    {:noreply, socket}
  end

  def new_filter(filter_states) do
    filter_states ++
      [
        %{
          selection: [],
          form: to_form(%{})
        }
      ]
  end
end
