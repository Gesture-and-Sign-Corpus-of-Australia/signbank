defmodule SignbankWeb.SignLive.Basic do
  use SignbankWeb, :live_view
  import SignbankWeb.SignComponents
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    if :sign in Map.keys(assigns) do
      ~H"""
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <nav class="flex flex-row justify-between mt-8">
          <div class="flex flex-row self-end">
            <.entry_nav sign={@sign} current_scope={@current_scope} />
            <div :if={!@sign.published} class="bg-striped">This entry is not published.</div>
          </div>
          <div class="border-none flex flex-row justify-self-end justify-end items-center text-right">
            <div :if={not Enum.empty?(@search_results)} class="search-matches">
              <div phx-no-format>
                Matches
                <span :if={@search_term != nil}>for the word <i>{@search_term}</i></span><span :if={
                  @handshape != nil
                }>with a {@handshape} handshape</span><span :if={@location != nil}> at {@location} location</span><%!--
                --%>:
              </div>
              <div class="input join gap-0 w-min p-0 border-none">
                <%= for {result, index} <- Enum.with_index(Enum.sort_by(@search_results, fn %{id_gloss: id_gloss} -> id_gloss end, :asc), 1) do %>
                  <.link
                    id={"search_result_#{result.id_gloss}"}
                    class={"join-item border-none btn #{if @sign.id_gloss == result.id_gloss do "bg-slate-300" end}"}
                    patch={~p"/dictionary/sign/#{result.id_gloss}?#{@query_params}"}
                    phx-click={JS.push_focus()}
                  >
                    {index}
                  </.link>
                <% end %>
              </div>
            </div>
          </div>
        </nav>

        <%!-- TODO: move onto video --%>
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
            <.live_component module={VideoScroller} counter={0} id={@sign.id} sign={@sign} />
            <.keywords sign={@sign} search_term={@search_term} />
            <.live_component
              module={SignbankWeb.CorpusExamples}
              id={"#{@sign.id}_corpus_examples"}
              gloss={@sign.id_gloss_annotation}
              version={:modal}
            />
            <div :if={Enum.count(@sign.suggested_signs) > 0} style="margin-top: 0.5em">
              <h2 class="is-size-5">Suggested signs</h2>
              <p>{@sign.suggested_signs_description}</p>
              <ul class="suggested_signs">
                <li :for={suggestion <- @sign.suggested_signs}>
                  <.modal id={"suggesed_sign_modal_#{suggestion.id}"}>
                    <video controls autoplay muted width="400">
                      <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{suggestion.url}"} />
                    </video>
                  </.modal>
                  <%!-- with preload="metadata" this functions as a thumbnail, although its not ideal --%>
                  <%!-- phx-click={show_modal("suggesed_sign_modal_#{suggestion.id}")} --%>
                  <video
                    onclick={"suggesed_sign_modal_#{suggestion.id}.showModal()"}
                    preload="metadata"
                    muted
                    width="100"
                  >
                    <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{suggestion.url}"} />
                  </video>
                </li>
              </ul>
            </div>
          </div>
          <div>
            <.definitions type={:basic} sign={@sign} />
          </div>
        </div>

        <%!-- TODO: add seealso/ant collapsible embeds --%>
      </Layouts.app>
      """
    else
      ~H"""
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <%= if @error do %>
          <p>There was an error attempting your search.</p>
        <% else %>
          <%= if not Enum.empty?(@inexact_matches) do %>
            <div>
              {Enum.count(@inexact_matches)} close matches found <hr />
              <ul class="keyword-disambig">
                <%= for [keyword, id_gloss, published] <- Enum.sort_by(@inexact_matches, fn s -> s |> Enum.at(0) |> String.downcase end) do %>
                  <li class="keyword-disambig__keyword" data-published={published}>
                    <.link href={~p"/dictionary/sign/#{id_gloss}?q=#{keyword}"}>{keyword}</.link>
                  </li>
                <% end %>
              </ul>
            </div>
          <% else %>
            <div class="content">
              <p>
                There is no exact match to the word you typed.
              </p>
              <p>
                There are three main reasons why there may be no match:
                <ol>
                  <li>
                    There really is no Auslan sign for which that word is a good translation (you may need to fingerspell the word).
                  </li>
                  <li>
                    You have mis-typed the word or you have added unnecessary word endings. Follow these search tips:
                    <ul>
                      <li>type only the first few letters of a word</li>
                      <li>type words with no word endings like ‘ing’, ‘ed’, or ‘s’.</li>
                    </ul>
                  </li>

                  <li>
                    The match is blocked in the public view of Auslan Signbank because the word/sign is obscene or offensive in English or Auslan, or both. (Schools and parents have repeatedly requested that these type of words/signs be only visible to registered users.) If you login or register with Signbank, you will then be able to find these matching words/signs if they exist in Auslan.
                  </li>
                </ol>
              </p>
            </div>
          <% end %>
        <% end %>
      </Layouts.app>
      """
    end
  end

  @impl true
  def handle_params(%{"id" => id_gloss} = params, _url, socket) do
    search_term = Map.get(params, "q")
    handshape = Map.get(params, "hs")
    location = Map.get(params, "loc")

    # TODO: there's a bug here, logged in editors shouldn't get a "no perms" error message for a 404
    case Dictionary.get_sign_by_id_gloss(id_gloss, socket.assigns.current_scope) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "You do not have permission to access this page, please log in.")
         |> redirect(to: ~p"/users/log-in")}

      sign ->
        socket =
          if handshape || location do
            assign(
              socket,
              :search_results,
              # TODO: shouldn't tie input here to specific shape of query params
              Dictionary.get_sign_by_phon_feature!(persist_query_params(params))
            )
          else
            search_results =
              if is_nil(search_term) do
                []
              else
                {:ok, search_results} = Dictionary.get_sign_by_keyword!(search_term)
                search_results
              end

            assign(socket, :search_results, search_results)
          end

        {:noreply,
         assign(
           socket,
           page_title: page_title(socket.assigns.live_action),
           sign: sign,
           handshape: handshape,
           location: location,
           query_params: persist_query_params(params),
           search_term: search_term
         )}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> assign(:inexact_matches, [])
      |> assign(:error, nil)

    search_term = Map.get(params, "q")

    handshape = Map.get(params, "hs")
    location = Map.get(params, "loc")

    if handshape || location do
      case Dictionary.get_sign_by_phon_feature!(persist_query_params(params)) do
        [] ->
          {:noreply, assign(socket, :error, gettext("No matches found."))}

        [first | _] ->
          {:noreply,
           push_patch(socket,
             to: ~p"/dictionary/sign/#{first.id_gloss}?#{persist_query_params(params)}"
           )}
      end
    else
      # TODO: we need to use `n` to get to a specific match number, but right now we can't
      # see other matches and they're not sorted properly anyway
      case Dictionary.fuzzy_find_keyword(search_term, socket.assigns.current_scope) do
        # if we match a keyword exactly, and its the only match, jump straight to results
        {:ok, [[^search_term, id_gloss, _]]} ->
          {:noreply,
           push_patch(socket,
             to: ~p"/dictionary/sign/#{id_gloss}?#{%{"q" => search_term}}"
           )}

        {:ok, []} ->
          {:noreply, assign(socket, :error, "No results found.")}

        {:ok, inexact_matches} ->
          {:noreply, assign(socket, :inexact_matches, inexact_matches)}
      end
    end
  end

  def persist_query_params(params) do
    Map.filter(params, fn {key, val} -> key in ["hs", "loc", "q"] and val not in ["", nil] end)
  end

  # TODO: fix the page title
  defp page_title(:show), do: gettext("Show sign")
  defp page_title(:edit), do: gettext("Edit sign")

  defp keywords(assigns) do
    ~H"""
    <p>
      <strong>Keywords:</strong>
      <%= case @sign.keywords do %>
        <% [] -> %>
          <em>this entry has no keywords</em>
        <% keywords -> %>
          <%= for {keyword, index} <- Enum.with_index(keywords, 1) do %>
            <span class={if keyword == @search_term, do: "font-bold"}>{keyword}</span><span :if={
              index < Enum.count(keywords)
            }>, </span>
          <% end %>
      <% end %>
    </p>
    """
  end
end
