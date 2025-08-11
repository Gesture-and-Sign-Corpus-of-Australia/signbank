defmodule SignbankWeb.SignComponents do
  @moduledoc """
  Components for displaying information about a sign.
  """
  use Phoenix.Component
  use Gettext, backend: Signbank.Gettext
  use Phoenix.VerifiedRoutes, endpoint: SignbankWeb.Endpoint, router: SignbankWeb.Router

  alias Phoenix.LiveView.JS
  alias Signbank.Accounts
  alias Signbank.Dictionary

  @role_order [
    :auslan,
    :general,
    :noun,
    :verb,
    :modifier,
    :augment,
    :pointing_sign,
    :interactive,
    :question,
    :note,
    :editor_note
  ]

  @editor_definitions [
    :editor_note
  ]

  defp group_definitions_by_role(definitions) do
    definitions
    |> Enum.group_by(fn def -> def.role end)
    |> Enum.to_list()
    |> Enum.sort_by(fn {role, _defs} ->
      Enum.find_index(
        @role_order,
        &(&1 == role)
      )
    end)
  end

  defp definition_role_to_string(:general), do: gettext("General Definition")
  defp definition_role_to_string(:auslan), do: gettext("Definition in Auslan")
  defp definition_role_to_string(:noun), do: gettext("As a Noun")
  defp definition_role_to_string(:verb), do: gettext("As a Verb or Adjective")
  defp definition_role_to_string(:modifier), do: gettext("As Modifier")
  defp definition_role_to_string(:augment), do: gettext("Augmented meaning")

  defp definition_role_to_string(:pointing_sign),
    do: gettext("As a Pointing Sign")

  defp definition_role_to_string(:question), do: gettext("As a question")
  defp definition_role_to_string(:interactive), do: gettext("Interactive")
  defp definition_role_to_string(:note), do: gettext("Note")
  defp definition_role_to_string(:editor_note), do: gettext("Editor note")

  attr :type, :atom, values: [:basic, :linguistic], required: true
  attr :sign, Dictionary.Sign, required: true
  attr :user, Accounts.User, required: false

  def definitions(assigns) do
    filter_unpublished = fn def ->
      if Accounts.can_see_unpublished?(assigns[:user]), do: true, else: def.published
    end

    filter_editor_defs = fn {role, _defs} ->
      if Accounts.can_see_unpublished?(assigns[:user]) do
        true
      else
        # to prevent new roles defaulting to being shown
        role in @role_order and
          role not in @editor_definitions
      end
    end

    definitions =
      assigns.sign.definitions
      |> Enum.concat(
        case assigns.sign do
          %Dictionary.Sign{
            citation: %Dictionary.Sign{definitions: definitions}
          } ->
            # TODO: once we switch to a :notes table table this is useless
            # Filter to use only the definitions (the other roles represent notes
            # and shouldn't be inherited by variants)
            Enum.filter(
              definitions,
              &(&1.role in [
                  :general,
                  :auslan,
                  :noun,
                  :verb,
                  :modifier,
                  :pointing_sign,
                  :questions,
                  :interactive
                ])
            )

          _ ->
            []
        end
      )
      |> Enum.filter(filter_unpublished)

    assigns =
      assign(
        assigns,
        :def_groups,
        definitions
        |> group_definitions_by_role()
        |> Enum.filter(filter_editor_defs)
      )

    ~H"""
    <div class="definitions flex flex-col gap-4">
      <div :for={{role, group} <- @def_groups} class="bg-white-200 shadow-sm p-4">
        <div class="text-lg">
          {definition_role_to_string(role)}
        </div>
        <ol class="definition__senses p-4">
          <li :for={definition <- group} class="list-decimal ml-2 only:list-none">
            <div>
              <SignbankWeb.CoreComponents.icon
                :if={not definition.published}
                name="hero-eye-slash"
                class="size-6"
              />
              <div>
                {Phoenix.HTML.raw(bold_english_keyword(definition.text))}
              </div>
              <video :if={definition.url} id={definition.url} controls muted width="200">
                <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{definition.url}"} />
              </video>
            </div>
          </li>
        </ol>
      </div>
    </div>
    """
  end

  defp bold_english_keyword(nil) do
    nil
  end

  defp bold_english_keyword(text) do
    [definition | rest] =
      Regex.split(
        ~r/.(\s\w+)? English =(\w*?)(.|$)/,
        text,
        include_captures: true,
        on: :all
      )

    bolded =
      rest
      |> Enum.chunk_every(2)
      |> Enum.map(fn [english_equals, keywords] ->
        english_equals <>
          Regex.replace(
            ~r/(\([^,;.]*\)\s?)?([-\w'‘’“”!? ]+)(?<bracketed>.? ?\[.*\] ?)?(\s?\([^,;.]*\))?(?=[,;.]|$){1}/,
            keywords,
            "\\1<b>\\2</b>\\3\\4"
          )
      end)

    Enum.join([
      definition,
      bolded
    ])
  end

  attr :class, :string, required: false
  attr :sign, Dictionary.Sign, required: false

  attr :view, :atom,
    values: [:basic, :detail, :edit],
    default: :basic,
    doc: "used to stay in the same view on navigation"

  attr :current_scope, Scope, required: false

  def entry_nav(assigns) do
    %{previous: previous, position: position, next: next} =
      Dictionary.get_prev_next_signs!(assigns.sign, Map.get(assigns, :current_scope))

    to_url = fn
      nil ->
        nil

      %Dictionary.Sign{id_gloss: id_gloss} ->
        case assigns.view do
          :basic ->
            ~p"/dictionary/sign/#{id_gloss}"

          :detail ->
            ~p"/dictionary/sign/#{id_gloss}/detail"

          :edit ->
            ~p"/dictionary/sign/#{id_gloss}/edit"
        end
    end

    assigns =
      assign(
        assigns,
        next: to_url.(next),
        previous: to_url.(previous),
        position: position,
        sign_count: Dictionary.count_signs(Map.get(assigns, :current_scope))
      )

    ~H"""
    <div class="flex flex-row gap-4">
      <div class="shrink-0 flex gap-4">
        <.link
          id={"search_result_#{@sign.id_gloss}_prev"}
          disabled={@previous == nil}
          class="btn"
          patch={@previous}
          phx-click={JS.push_focus()}
        >
          Previous
        </.link>
        <div class="text-center content-center leading-none">
          Sign {@position}<br /> of {@sign_count}
        </div>
        <.link
          id={"search_result_#{@sign.id_gloss}_next"}
          disabled={@next == nil}
          class="btn"
          patch={@next}
          phx-click={JS.push_focus()}
        >
          Next
        </.link>
      </div>

      <.link :if={@view == :detail} class="btn" patch={~p"/dictionary/sign/#{@sign.id_gloss}"}>
        {gettext("Go to basic view")}
      </.link>
      <.link :if={@view != :detail} class="btn" patch={~p"/dictionary/sign/#{@sign.id_gloss}/detail"}>
        {gettext("Go to detailed view")}
      </.link>
    </div>
    """
  end
end
