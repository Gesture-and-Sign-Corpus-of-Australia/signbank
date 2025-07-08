defmodule SignbankWeb.SignLive.Edit do
  use SignbankWeb, :live_view
  import SignbankWeb.SignComponents
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      allow_upload(
        socket,
        :video,
        accept: ~w(.mp4),
        max_entries: 1,
        external: &presign_upload/2,
        progress: &handle_upload_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  defp update_touched?(socket) do
    assign(socket, touched: !Enum.empty?(socket.assigns.form.source.changes))
  end

  defp init(socket, sign) do
    changeset = Dictionary.Sign.changeset(sign, %{})

    socket
    |> assign(
      sign: sign,
      form: to_form(changeset),
      # Reset form for LV
      id: "form-#{System.unique_integer()}"
    )
    |> update_touched?()
  end

  @impl true
  def handle_params(%{"id" => id_gloss}, _, socket) do
    sign = Dictionary.get_sign_by_id_gloss(id_gloss, socket.assigns.current_scope)

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

    {:noreply,
     assign(socket,
       form: to_form(changeset),
       touched: !Enum.empty?(changeset.changes)
     )}
  end

  def handle_event("add-definition", _params, socket) do
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

  defp handle_upload_progress(:video, entry, socket) do
    if entry.done? do
      uploaded_file =
        consume_uploaded_entry(socket, entry, fn %{key: path} ->
          {:ok, path}
        end)

      {:ok, video} =
        Dictionary.create_video(%{
          url: uploaded_file,
          sign_id: socket.assigns.sign.id
        })

      socket =
        update(socket, :form, fn %{source: changeset} ->
          existing = Ecto.Changeset.get_assoc(changeset, :videos)

          changeset =
            changeset
            |> Ecto.Changeset.put_assoc(
              :videos,
              existing ++ [video]
            )
            |> Ecto.Changeset.put_assoc(:active_video, video)

          to_form(changeset)
        end)

      {:noreply, put_flash(socket, :info, "file uploaded") |> update_touched?()}
    else
      {:noreply, socket}
    end
  end

  def video(assigns) do
    ~H"""
    <div
      id={"sign_video_#{@f[:id].value}"}
      class={[
        "video",
        if(false, do: "opacity-50", else: ""),
        if(@is_active_video, do: "border border-2 color-slate-800;", else: "")
      ]}
    >
      <div class="level mb-0">
        <.button
          form={@form}
          type="button"
          name="sign[videos_drop][]"
          value={@f.index}
          phx-click={JS.dispatch("change")}
          title="delete video"
        >
          <.icon name="hero-x-mark" />
        </.button>
        <%= if is_nil(@f[:id].value) do %>
          <.button
            form={@form}
            class="cursor-not-allowed"
            title="Please save before setting as active video"
            disabled
            type="button"
          >
            <.icon name="hero-arrow-up" />
          </.button>
        <% else %>
          <.button
            form={@form}
            title="Set as active video"
            type="button"
            phx-value-id={@f[:id].value}
            phx-click="set-active-video"
          >
            <.icon name="hero-arrow-up" />
          </.button>
        <% end %>
      </div>

      <video controls="" muted="" autoplay="" width="600">
        <source src={
          Path.join(
            Application.fetch_env!(:signbank, :media_url),
            @f[:url].value || "missing-video.mp4"
          )
        } />
      </video>
      <.input type="hidden" form={@form} field={@f[:url]} />
      <.input type="hidden" form={@form} field={@f[:id]} />
    </div>
    """
  end

  def definition(assigns) do
    # TODO: refactor delete to go through cast_assocs's `sort_param` to match how sorting works
    assigns = assign(assigns, :deleted, Phoenix.HTML.Form.input_value(assigns.f, :delete) == true)

    ~H"""
    <%!-- TODO: move to CSS file --%>
    <div class={["definition", if(@deleted, do: "opacity-50", else: "")]}>
      <div data-drag-handle class="drag-handle flex items-center">
        <.icon name="hero-bars-2" />
      </div>
      <div class="flex flex-col grow">
        <div class="level">
          <.input form={@form} type="hidden" class="textarea resize-y" rows="7" field={@f[:id]} />
          <input form={@form} type="hidden" name="sign[definitions_position][]" } value={@f.index} />
          <input
            form={@form}
            type="hidden"
            name={Phoenix.HTML.Form.input_name(@f, :delete)}
            value={to_string(Phoenix.HTML.Form.input_value(@f, :delete))}
          />
          <.input
            form={@form}
            type="select"
            field={@f[:role]}
            label="Role"
            options={Signbank.Dictionary.Definition.roles()}
          />
          <.input
            form={@form}
            type="select"
            field={@f[:language]}
            label="Language"
            options={[:en, :asf]}
          />
        </div>
        <%= if Signbank.signed_language?(@f[:language].value) do %>
          <%!-- TODO: add video upload functionality here --%>
          <.input form={@form} type="text" field={@f[:url]} label="URL" />
        <% else %>
          <%!-- TODO: move styles to CSS --%>
          <.input
            form={@form}
            type="textarea"
            class="textarea resize-y"
            rows="7"
            field={@f[:text]}
            label="Text"
          />
        <% end %>
        <div class="level">
          <.input form={@form} type="checkbox" field={@f[:published]} label="Published" />
          <.button
            form={@form}
            type="button"
            phx-value-index={@f.index}
            phx-click="toggle-delete-definition"
          >
            <%= if @deleted do %>
              Undelete?
            <% else %>
              Delete?
            <% end %>
          </.button>
        </div>
      </div>
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
      <%!-- <.label for={@id}>{@label}</.label> --%>
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
      <%!-- <.error :for={msg <- @errors}>{msg}</.error> --%>
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

  def video_manager(assigns) do
    ~H"""
    <SignbankWeb.Modal.modal id={@id}>
      <:modal_box>
        <.inputs_for :let={f_video} field={@form[:videos]}>
          <.video
            form="sign-form"
            f={f_video}
            is_active_video={
              if(@form[:active_video].value,
                do: @form[:active_video].value.id == f_video[:id].value,
                else: false
              )
            }
          />
        </.inputs_for>
        <input type="hidden" name="sign[videos_drop][]" />

        <label for={@uploads.video.ref}>Upload new video:</label>
        <.live_file_input class="file-input" form="sign-form" upload={@uploads.video} />
        <SignbankWeb.Modal.modal_action>
          <.button>Confirm</.button>
        </SignbankWeb.Modal.modal_action>
      </:modal_box>
    </SignbankWeb.Modal.modal>
    """
  end
end
