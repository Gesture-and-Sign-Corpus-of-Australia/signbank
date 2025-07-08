defmodule SignbankWeb.SignLive.Detail do
  use SignbankWeb, :live_view
  import SignbankWeb.SignComponents
  import SignbankWeb.MapComponents
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @impl true
  def mount(params, _session, socket) do
    {:ok, assign(socket, :params, params)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <nav class="flex flex-row justify-between mt-8">
        <.entry_nav sign={@sign} current_scope={@current_scope} view={:detail} />
        <.link
          :if={@current_scope && @current_scope.user.role in [:tech, :editor]}
          class="btn"
          patch={~p"/dictionary/sign/#{@sign.id_gloss}/edit"}
        >
          {gettext("Edit entry")}
        </.link>
      </nav>
      <div :if={@sign.sense_number} class="level">
        <p :if={@sign.sense_number == 1}>
          {gettext(
            "This sign has two or more completely separate meanings. Click Next to see the other ones."
          )}
        </p>
        <p :if={@sign.sense_number > 1}>
          {gettext(
            "This sign has two or more completely separate meanings. Click Next and Previous to see the other ones."
          )}
        </p>
      </div>

      <div class="flex gap-4">
        <div>
          <%!-- TODO: refactor along with video_scroller.ex --%>
          <div class={["video-frame", video_frame_class(@sign)]}>
            <div class="video-frame__video_wrapper">
              <video controls muted autoplay width="600" id={"#{@sign.id}_video"}>
                <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{Enum.at(@sign.videos,0).url}"} />
              </video>
              <p class="video-frame__sign-type">{video_frame_type(@sign)}</p>
            </div>
          </div>
          <p><strong>Keywords:</strong> {Enum.join(@sign.keywords || [], ", ")}</p>

          <hr />

          <div :if={@sign.type == :citation and Enum.count(@sign.variants) > 0} class="box">
            <h3 class="text-lg">Variants</h3>
            <ol class="entry-page__variant_list">
              <%= for {variant, index} <- Enum.with_index(@sign.variants, 1) do %>
                <li>
                  <.link class="btn" href={~p"/dictionary/sign/#{variant.id_gloss}/detail?#{@params}"}>
                    {index}
                  </.link>
                </li>
              <% end %>
            </ol>
          </div>

          <div :if={@sign.type == :variant}>
            <.link
              class="btn inline-flex items-center"
              href={~p"/dictionary/sign/#{@sign.citation.id_gloss}/detail?#{@params}"}
            >
              Citation form <.icon name="hero-chevron-right" />
            </.link>
          </div>
        </div>

        <div class="flex flex-col gap-4">
          <table class="summary-table">
            <%= for field <- [
              :id_gloss,
              :id_gloss_annotation,
              :keywords
            ] do %>
              <tr>
                <th>
                  {Gettext.gettext(Signbank.Gettext, Atom.to_string(field))}
                </th>
                <td>
                  <%= with value <- Map.get(@sign, field) do %>
                    <%= if is_list(value) do %>
                      {Enum.join(value, ", ")}
                    <% else %>
                      {value}
                    <% end %>
                  <% end %>
                </td>
              </tr>
            <% end %>
            <tr :if={@current_scope && Map.get(@current_scope, :role) in [:tech, :editor]}>
              <th>
                {Gettext.gettext(Signbank.Gettext, "published")}
              </th>
              <td>{@sign.published}</td>
            </tr>
          </table>

          <.details_accordion sign={@sign} current_scope={@current_scope} />

          <hr />

          <.definitions type={:linguistic} user={@current_scope} sign={@sign} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_params(%{"id" => id_gloss}, _, socket) do
    case Dictionary.get_sign_by_id_gloss(id_gloss, socket.assigns.current_scope) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "You do not have permission to access this page, please log in.")
         |> redirect(to: ~p"/users/log-in")}

      sign ->
        {:noreply,
         socket
         |> assign(:page_title, "Show sign")
         |> assign(:sign, sign)}
    end
  end

  defp list_flags(flags) do
    with flags <- flags |> Map.filter(fn {_, v} -> v end) |> Map.keys() do
      Enum.join(
        if(Enum.empty?(flags), do: ["none"], else: flags),
        ", "
      )
    end
  end

  defp generate_initial_final_text(initial, final) when initial == final or final in ["", nil],
    do: "#{initial}"

  defp generate_initial_final_text(initial, final), do: "#{initial} → #{final}"

  defp video_frame_type(sign) do
    cond do
      sign.english_entry -> "fingerspelled"
      sign.is_signed_english_only -> "Signed English-only"
      sign.type == :citation -> "citation"
      sign.type == :variant -> "variant"
    end
  end

  defp video_frame_class(sign) do
    if sign.english_entry do
      "english_entry"
    else
      if sign.is_signed_english_only do
        "se_only"
      else
        Atom.to_string(sign.type)
      end
    end
  end

  defp bool_to_word(true), do: gettext("yes")
  defp bool_to_word(false), do: gettext("no")
  defp bool_to_word(_), do: gettext("unknown")

  def details_accordion(assigns) do
    ~H"""
    <div class="join join-vertical bg-base-100">
      <div class="collapse collapse-arrow join-item border-base-300 border">
        <input type="radio" name="details-accordion" />
        <div class="collapse-title bg-base-200">
          <h2 class="text-md font-semibold" aria-label="Vocabulary:">Vocabulary</h2>
          <span class="text-sm">usage &ndash; meaning &ndash; dialect</span>
        </div>
        <div class="collapse-content text-sm">
          <.vocab_details sign={@sign} current_scope={@current_scope} />
        </div>
      </div>

      <div class="collapse collapse-arrow join-item border-base-300 border">
        <input type="radio" name="details-accordion" />
        <div class="collapse-title bg-base-200">
          <h2 class="text-md font-semibold" aria-label="Vocabulary:">Morphology</h2>
          <span class="text-sm">spatial &ndash; lexical</span>
        </div>
        <div class="collapse-content text-sm">
          <.morph_details sign={@sign} current_scope={@current_scope} />
        </div>
      </div>

      <div class="collapse collapse-arrow join-item border-base-300 border">
        <input type="radio" name="details-accordion" />
        <div class="collapse-title bg-base-200">
          <h2 class="text-md font-semibold" aria-label="Vocabulary:">Phonology</h2>
          <span class="text-sm">movement &ndash; orientation &ndash; location</span>
        </div>
        <div class="collapse-content text-sm">
          <.phon_details sign={@sign} current_scope={@current_scope} />
        </div>
      </div>
    </div>
    """
  end

  def vocab_details(assigns) do
    ~H"""
    <div class="mt-2">
      <div :if={SignbankWeb.MapComponents.show_map?(@sign.regions)}>
        <h3 class="is-size-6 has-text-weight-semibold">Dialects</h3>
        <%= if Enum.any?(@sign.regions) do %>
          <.australia_map selected={@sign.regions} />
        <% else %>
          Unknown
        <% end %>
      </div>
      <div>
        <h3 class="is-size-6 has-text-weight-semibold">Usage by other factors</h3>
        <ul class="ling-details-section__properties">
          <li>
            Technical or specialist jargon: {bool_to_word(@sign.lexis_technical_or_specialist_jargon)}
          </li>
          <li>Marginal/minority: {bool_to_word(@sign.lexis_marginal_or_minority)}</li>
          <li>Obsolete: {bool_to_word(@sign.lexis_obsolete)}</li>
          <li>Anglican/state school: {bool_to_word(@sign.school_anglican_or_state)}</li>
          <li>
            Catholic school: {bool_to_word(@sign.school_catholic)}
          </li>
          <li>Crude?: {bool_to_word(@sign.crude)}</li>
        </ul>
      </div>
      <div>
        <h3 class="is-size-6 has-text-weight-semibold">Borrowings</h3>
        <ul class="ling-details-section__properties">
          <li>ASL gloss: {if @sign.asl_gloss, do: @sign.asl_gloss, else: "N/A"}</li>
          <li>ASL loan?: {bool_to_word(@sign.is_asl_loan)}</li>
          <li>BSL gloss: {if @sign.bsl_gloss, do: @sign.bsl_gloss, else: "N/A"}</li>
          <li>BSL loan?: {bool_to_word(@sign.is_bsl_loan)}</li>
          <li>
            Signed English gloss: {if @sign.signed_english_gloss,
              do: @sign.signed_english_gloss,
              else: "N/A"}
          </li>
          <li :if={@sign.signed_english_gloss}>
            <%!-- I have elected to show this only if there is an SE gloss, I believe it is confusing otherwise --%>
            Signed English Only?: {bool_to_word(@sign.is_signed_english_only)}
          </li>
        </ul>
      </div>
      <div>
        <h3 class="is-size-6 has-text-weight-semibold">Other</h3>
        <ul class="ling-details-section__properties">
          <li>
            Iconicity: {@sign.iconicity || gettext("unknown")}
          </li>
          <li :if={@sign.popular_explanation}>
            Popular explanation: {@sign.popular_explanation}
          </li>
          <li :if={Enum.count(@sign.semantic_categories) > 0}>
            Semantic category: {@sign.semantic_categories
            |> Enum.map(fn c -> c.name end)
            |> Enum.join(", ")}
          </li>

          <%!-- as yet unimplemented:
            <li>Corpus attested: </li>
          --%>
        </ul>
      </div>
    </div>
    """
  end

  def morph_details(assigns) do
    ~H"""
    <div class="pt-2">
      <ul class="ling-details-section__properties">
        <li>
          Blend of: {if @sign.morphology.blend_of,
            do: "‘#{@sign.morphology.blend_of}’",
            else: "N/A"}
        </li>
        <li>
          Calque of: {if @sign.morphology.calque_of,
            do: "‘#{@sign.morphology.calque_of}’",
            else: "N/A"}
        </li>
        <li>
          Compound of: {if @sign.morphology.compound_of,
            do: "‘#{@sign.morphology.compound_of}’",
            else: "N/A"}
        </li>
        <li>
          Idiom of: {if @sign.morphology.idiom_of,
            do: "‘#{@sign.morphology.idiom_of}’",
            else: "N/A"}
        </li>

        <li>
          This sign {if @sign.morphology.multi_sign_expression, do: "is", else: "is not"} a multi-sign expression.
        </li>
        <%!-- TODO: refactor this hack into some kind of require_editor() fn, this approach will get annoying the more things we need to hide from unauthed users --%>
        <li :if={
          @sign.phonology.hamnosys_variant_analysis && @current_scope &&
            @current_scope.user.role in [:tech, :editor]
        }>
          HamNoSys variant analysis:
          <span class="hamnosys">{@sign.phonology.hamnosys_variant_analysis}</span>
        </li>
      </ul>
      <div>
        <h3 class="is-size-6 has-text-weight-semibold">Spatial</h3>
        <ul class="ling-details-section__properties">
          <li>Directional: {bool_to_word(@sign.morphology.directional)}</li>
          <li>
            Begins directional: {bool_to_word(@sign.morphology.beginning_directional)}
          </li>
          <li>
            Ends directional: {bool_to_word(@sign.morphology.end_directional)}
          </li>
          <li>Orientating: {bool_to_word(@sign.morphology.orientating)}</li>
          <li>
            Body locating: {bool_to_word(@sign.morphology.body_locating)}
          </li>
        </ul>
      </div>
      <div>
        <h3 class="is-size-6 has-text-weight-semibold">Lexical</h3>
        <ul class="ling-details-section__properties">
          <li>Initialism: {bool_to_word(@sign.morphology.is_initialism)}</li>
          <li>Alphabet: {bool_to_word(@sign.morphology.is_alphabet)}</li>
          <li>Abbreviation: {bool_to_word(@sign.morphology.is_abbreviation)}</li>
        </ul>
      </div>
    </div>
    """
  end

  def phon_details(assigns) do
    ~H"""
    <div class="pt-2">
      <ul>
        <li>
          Dominant handshape: {generate_initial_final_text(
            Signbank.Dictionary.Phonology.Handshape.to_string(
              @sign.phonology.dominant_initial_handshape
            ),
            Signbank.Dictionary.Phonology.Handshape.to_string(
              @sign.phonology.dominant_final_handshape
            )
          )}
        </li>
        <li>
          Subordinate handshape: {generate_initial_final_text(
            Signbank.Dictionary.Phonology.Handshape.to_string(
              @sign.phonology.subordinate_initial_handshape
            ),
            Signbank.Dictionary.Phonology.Handshape.to_string(
              @sign.phonology.subordinate_final_handshape
            )
          )}
        </li>
        <li>
          Primary location: {generate_initial_final_text(
            Signbank.Dictionary.Phonology.Location.to_string(
              @sign.phonology.initial_primary_location
            ),
            Signbank.Dictionary.Phonology.Location.to_string(@sign.phonology.final_primary_location)
          )}
        </li>
        <li>
          Location side: {if not is_nil(@sign.phonology.location_rightside_or_leftside) do
            Signbank.Dictionary.Phonology.Side.to_string(
              @sign.phonology.location_rightside_or_leftside
            )
          else
            gettext("unknown")
          end}
        </li>
        <%!-- TODO: refactor this hack into some kind of require_editor() fn, this approach will get annoying the more things we need to hide from unauthed users --%>
        <li :if={
          @sign.phonology.hamnosys && @current_scope &&
            @current_scope.user.role in [:tech, :editor]
        }>
          HamNoSys: <span class="hamnosys">{@sign.phonology.hamnosys}</span>
        </li>
      </ul>
      <div>
        <h3 class="is-size-6 has-text-weight-semibold">
          Finger-hand <small>(metacarpus)</small> orientation
        </h3>
        <ul class="ling-details-section__properties">
          <li>
            Dominant finger-hand orientation: {generate_initial_final_text(
              @sign.phonology.dominant_initial_finger_hand_orientation,
              @sign.phonology.dominant_final_finger_hand_orientation
            )}
          </li>
          <li>
            Subordinate finger-hand orientation: {generate_initial_final_text(
              @sign.phonology.subordinate_initial_finger_hand_orientation,
              @sign.phonology.subordinate_final_finger_hand_orientation
            )}
          </li>
        </ul>
      </div>
      <%!-- TODO: the FM database has palm orientation, track down whether we need it or not --%>

      <div>
        <h3 class="is-size-6 has-text-weight-semibold">
          Interact location <small>(not for one-handed signs)</small>
        </h3>
        <ul class="ling-details-section__properties">
          <li>
            Dominant interacting handpart: {generate_initial_final_text(
              @sign.phonology.dominant_initial_interacting_handpart,
              @sign.phonology.dominant_final_interacting_handpart
            )}
          </li>
          <li>
            subordinate interacting handpart: {generate_initial_final_text(
              @sign.phonology.subordinate_initial_interacting_handpart,
              @sign.phonology.subordinate_final_interacting_handpart
            )}
          </li>

          <%= with contact <- list_flags(%{
                gettext("start") => @sign.phonology.contact_start,
                gettext("end") => @sign.phonology.contact_end,
                gettext("during") => @sign.phonology.contact_during,
                gettext("hands") => @sign.phonology.contact_hands,
                gettext("body") => @sign.phonology.contact_body,
              }) do %>
            <li>Contact: {contact}</li>
          <% end %>

          <%= with changes <- list_flags(%{
                gettext("handshape") => @sign.phonology.change_handshape,
                gettext("open") => @sign.phonology.change_open,
                gettext("close") => @sign.phonology.change_close,
                gettext("orientation") => @sign.phonology.change_orientation,
              }) do %>
            <li>
              Changes <small>(dominant hand)</small>: {changes}
            </li>
          <% end %>
        </ul>
      </div>

      <div>
        <h3 class="is-size-6 has-text-weight-semibold">
          Small hand movements <small>(dominant hand)</small>
        </h3>
        <%= for {label, value} <- %{
                gettext("forearm rotates") => @sign.phonology.movement_forearm_rotation,
                gettext("wrist nods") => @sign.phonology.movement_wrist_nod,
                gettext("fingers straightens") => @sign.phonology.movement_fingers_straighten,
                gettext("fingers wiggle") => @sign.phonology.movement_fingers_wiggle,
                gettext("fingers crumble") => @sign.phonology.movement_fingers_crumble,
                gettext("fingers bend") => @sign.phonology.movement_fingers_bend,
              } do %>
          <div>
            <input disabled type="checkbox" id={label} name={label} checked={value} />
            <label for={label}>{label}</label>
          </div>
        <% end %>
      </div>

      <div>
        <h3 class="is-size-6 has-text-weight-semibold">
          Large movements <small>(interactions of hands) — Two-handed signs only</small>
        </h3>
        <%= for {label, value} <- %{
                gettext("dominant hand only") => @sign.phonology.movement_dominant_hand_only,
                gettext("symmetrical") => @sign.phonology.movement_symmetrical,
                gettext("parallel") => @sign.phonology.movement_parallel,
                gettext("alternating") => @sign.phonology.movement_alternating,
                gettext("away") => @sign.phonology.movement_separating,
                gettext("towards") => @sign.phonology.movement_approaching,
                gettext("cross") => @sign.phonology.movement_cross,
              } do %>
          <div>
            <input disabled type="checkbox" id={label} name={label} checked={value} />
            <label for={label}>{label}</label>
          </div>
        <% end %>
      </div>

      <div>
        <h3 class="is-size-6 has-text-weight-semibold">
          Large movements <small>(dominant hand)</small>
        </h3>
        <ul class="ling-details-section__properties">
          <li :if={@sign.phonology.movement_direction}>
            Direction: {@sign.phonology.movement_direction}
          </li>
          <li :if={@sign.phonology.movement_path}>
            Path: {@sign.phonology.movement_path}
          </li>
          <li :if={@sign.phonology.movement_path}>
            Repetition: {@sign.phonology.movement_repeated}
          </li>
          <li>
            Handedness: {@sign.phonology.handedness}
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
