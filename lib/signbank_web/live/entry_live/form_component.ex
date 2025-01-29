defmodule SignbankWeb.SignLive.FormComponent do
  use SignbankWeb, :live_component

  alias Signbank.Dictionary

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="sign-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.inputs_for :let={vid} field={@form[:videos]}>
          <.input field={vid[:url]} />
        </.inputs_for>
        <label for={@uploads.video.ref}>Add new video</label>
        <.live_file_input upload={@uploads.video} />
        <.input field={@form[:id_gloss]} label={gettext("ID gloss")} />
        <.input field={@form[:id_gloss_annotation]} label={gettext("Annotation ID gloss")} />
        <.input
          field={@form[:keywords]}
          label={gettext("Keywords")}
          value={
            @form[:keywords].value
            |> List.wrap()
            |> Enum.join(", ")
          }
        />
        <.input field={@form[:variant_of]} label={gettext("Variant of")} />
        <%!-- TODO: regions --%>
        <%!-- TODO: phonology --%>
        <%!-- TODO: morphology --%>
        <%!-- TODO: relations --%>
        <%!-- TODO: definitions --%>
        <%!-- TODO: publish button --%>
        <%!-- TODO: language --%>
        <%!-- TODO: tags --%>

        <:actions>
          <.button phx-disable-with={gettext("Saving...")}>{gettext("Save sign")}</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{sign: sign} = assigns, socket) do
    changeset = Dictionary.change_sign(sign)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> allow_upload(:video, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"sign" => sign_params}, socket) do
    changeset =
      socket.assigns.sign
      |> Dictionary.change_sign(cast_keywords(sign_params))
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"sign" => sign_params}, socket) do
    sign_params =
      sign_params
      |> cast_keywords()
      |> with_video_url(socket)

    save_sign(socket, socket.assigns.action, sign_params)
  end

  defp cast_keywords(%{"keywords" => keywords} = params) do
    Map.put(
      params,
      "keywords",
      keywords
      |> String.split(",")
      |> Enum.map(&String.trim(&1))
    )
  end

  defp cast_keywords(params), do: params

  defp with_video_url(sign_params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :video, fn _, entry ->
        {:ok, SimpleS3Upload.entry_url(entry)}
      end)

    # check if there were uploaded files
    # assume there are

    Map.put(
      sign_params,
      "videos",
      [
        %{
          sign_id: socket.assigns.sign.id,
          url: Enum.at(uploaded_files, 0)
        }
      ]
    )
  end

  defp save_sign(socket, :edit, sign_params) do
    case Dictionary.update_sign(
           socket.assigns.sign,
           sign_params
         ) do
      {:ok, sign} ->
        notify_parent({:saved, sign})

        {:noreply,
         socket
         |> put_flash(:info, "Sign updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_sign(socket, :new, sign_params) do
    case Dictionary.create_sign(sign_params) do
      {:ok, sign} ->
        notify_parent({:saved, sign})

        {:noreply,
         socket
         |> put_flash(:info, "Sign created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
