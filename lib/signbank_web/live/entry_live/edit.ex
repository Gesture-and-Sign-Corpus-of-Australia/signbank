defmodule SignbankWeb.SignLive.Edit do
  use SignbankWeb, :live_view
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    # socket =
    #   socket
    #   |> allow_upload(:image,
    #     accept: ~w(.jpg .jpeg .png),
    #     max_entries: 1,
    #     external: &presign_upload/2
    #   )

    {:ok, socket}
  end

  defp init(socket, sign) do
    changeset = Dictionary.Sign.changeset(sign, %{})

    assign(socket,
      sign: sign,
      form: to_form(changeset),
      # Reset form for LV
      id: "form-#{System.unique_integer()}"
    )
  end

  @impl true
  def handle_params(%{"id" => id_gloss}, _, socket) do
    sign = Dictionary.get_sign_by_id_gloss(id_gloss, socket.assigns.current_user)

    {:noreply,
     socket
     |> assign(:page_title, "edit entry")
     |> assign(:sign, sign)
     |> init(sign)}
  end

  @impl true
  def handle_event("save", %{"sign" => sign_params}, socket) do
    case Dictionary.update_sign(socket.assigns.sign, sign_params) do
      {:ok, data} ->
        {:noreply, socket |> put_flash(:info, "Updated successfully") |> init(data)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"sign" => sign_params}, socket) do
    changeset =
      socket.assigns.sign
      |> Dictionary.change_sign(sign_params)
      |> struct!(action: :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("add-definition", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_assoc(changeset, :definitions)

        changeset =
          Ecto.Changeset.put_assoc(
            changeset,
            :definitions,
            existing ++ [%{}]
          )

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("toggle-delete-definition", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing =
          Ecto.Changeset.get_assoc(changeset, :definitions)

        {to_delete, rest} = List.pop_at(existing, index)

        definitions =
          cond do
            # if it has no ID then it has never been committed to the DB and we can throw it out
            not Map.has_key?(Ecto.Changeset.change(to_delete).data, :id) ->
              rest

            # revert deletion
            Ecto.Changeset.get_change(to_delete, :delete) ->
              List.replace_at(existing, index, Ecto.Changeset.delete_change(to_delete, :delete))

            true ->
              List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          end

        changeset
        |> Ecto.Changeset.put_assoc(:definitions, definitions)
        |> to_form()
      end)

    {:noreply, socket}
  end

  defp presign_upload(entry, %{assigns: %{uploads: uploads}} = socket) do
    meta = SimpleS3Upload.meta(entry, uploads)
    {:ok, meta, socket}
  end

  def definition(assigns) do
    # TODO: refactor delete to go through cast_assocs's `sort_param` to match how sorting works
    assigns = assign(assigns, :deleted, Phoenix.HTML.Form.input_value(assigns.f, :delete) == true)

    ~H"""
    <%!-- TODO: move to CSS file --%>
    <div style={"display:flex;border: 1px solid black;background-color:white;margin-bottom: 20px;"<>(if @deleted, do: "opacity: 50%;", else: "")}>
      <Heroicons.bars_2 data-drag-handle />
      <input type="hidden" name="sign[definitions_position][]" } value={@f.index} />
      <input
        type="hidden"
        name={Phoenix.HTML.Form.input_name(@f, :delete)}
        value={to_string(Phoenix.HTML.Form.input_value(@f, :delete))}
      />
      <.input
        type="select"
        field={@f[:role]}
        label="Role"
        options={Signbank.Dictionary.Definition.roles()}
      />
      <.input type="select" field={@f[:language]} label="Language" options={[:en, :asf]} />
      <.input type="textarea" field={@f[:text]} label="Text" />
      <.input type="text" field={@f[:url]} label="URL" />
      <.input type="checkbox" field={@f[:published]} label="Published" />
      <.button type="button" phx-value-index={@f.index} phx-click="toggle-delete-definition">
        <%= if @deleted do %>
          Undelete?
        <% else %>
          Delete?
        <% end %>
      </.button>
    </div>
    """
  end

  attr :id, :any
  attr :name, :any
  attr :label, :string, default: nil
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :options, :list
  attr :rest, :global, include: ~w(disabled form readonly)
  attr :class, :string, default: nil

  def regions_checkgroup(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(id: field.id)
      |> assign(:value, field.value)
      |> assign(:name, field.name <> "[]")
      |> assign(:errors, field.errors)
      |> assign_new(
        :selected,
        &pick_selected/1
      )

    ~H"""
    <div phx-feedback-for={@name} class="text-sm">
      <.label for={@id}><%= @label %></.label>
      <div>
        <%!-- <div>
          <input type="hidden" name={@name} value="" />
          <ul :for={value <- @selected}><%= value %></ul>
          <div :for={{label, value} <- @options} class="flex items-center">
            <label for={"#{@name}-#{value}"}>
              <input
                type="checkbox"
                id={"#{@name}-#{value}"}
                name={@name}
                value={value}
                checked={Atom.to_string(value) in @selected}
                {@rest}
              />
              <%= label %> value: <%= value %>
            </label>
          </div>
        </div> --%>
      </div>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  defp pick_selected(assigns) do
    assigns.value
    |> Enum.map(fn x ->
      case x do
        %Ecto.Changeset{action: action, data: data} when action in [:insert, :update] ->
          data.region

        %Ecto.Changeset{} ->
          nil

        %{region: region} ->
          region

        "" ->
          nil

        x when is_binary(x) ->
          x

        _ ->
          nil
      end
    end)
    |> Enum.filter(&(!is_nil(&1)))
  end
end
