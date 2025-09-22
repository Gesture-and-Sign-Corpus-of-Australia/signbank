defmodule SignbankWeb.SignLive.Basic do
  use SignbankWeb, :live_view
  import SignbankWeb.SignComponents
  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @impl true
  def mount(params, _session, socket) do
    id_gloss = Map.get(params, "id")
    search_term = Map.get(params, "q")
    handshape = Map.get(params, "hs")
    location = Map.get(params, "loc")

    socket =
      assign(socket,
        error: nil,
        inexact_matches: [],
        query_params: persist_query_params(params),
        search_term: search_term,
        handshape: handshape,
        location: location
      )

    socket =
      cond do
        # if we get handshape and/or location then ignore `q`
        handshape || location ->
          # TODO published? check against scope, if necessary; sign_order might already do it
          assign(socket,
            search_results:
              Dictionary.get_sign_by_phon_features!(
                handshape,
                location,
                socket.assigns.current_scope
              )
          )

        # If we don't have an ID gloss, then we want to disambiguate `q`
        id_gloss ->
          socket =
            if search_term do
              case keyword_search(search_term, socket.assigns.current_scope) do
                # We don't care if results is [], the page will look fine either way
                {:ok, results} ->
                  assign(socket, search_results: results)

                {:multiple, results} ->
                  assign(socket,
                    search_results:
                      results
                      |> Enum.find(fn {kw, _, _} ->
                        # Treat the query as an exact keyword, so skip disambiguation
                        kw == search_term
                      end)
                      |> elem(1)
                      # HACK: deduplicate because a sign having two keywords with only different casing (i.e., FS:Q having "q" and "Q") it produced two results
                      |> Enum.dedup()
                  )
              end
            else
              socket
            end

          assign(socket, sign: load_sign(Map.get(params, "id"), socket.assigns.current_scope))

        # If we have an ID, then `q` is already an exact keyword and we're viewing a result
        true ->
          case keyword_search(Map.get(params, "q"), socket.assigns.current_scope) do
            {:ok, []} ->
              assign(
                socket,
                error: "No matches"
              )

            {:ok, results} ->
              assign(
                socket,
                search_results: results
              )

            {:multiple, inexact_matches} ->
              assign(
                socket,
                search_results: inexact_matches
              )
          end
      end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    if :sign in Map.keys(assigns) do
      ~H"""
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <nav class="flex flex-col w-full md:w-unset md:flex-row justify-between mt-4">
          <div class="flex flex-col w-full md:w-unset md:flex-row gap-4 self-end">
            <.entry_nav sign={@sign} current_scope={@current_scope} />
            <div :if={!@sign.published} class="bg-striped p-2">This entry is not published.</div>
          </div>
          <.search_results
            current={@sign.id_gloss}
            search_results={assigns[:search_results]}
            query_params={@query_params}
          />
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
        <div class="flex gap-4 flex-col md:flex-row">
          <div class="w-full md:w-[60vw] max-w-[450px] grow-0 shrink-0">
            <.live_component module={VideoScroller} counter={0} id={@sign.id} sign={@sign} />
            <.keywords sign={@sign} search_term={assigns.query_params["q"]} />
            <.live_component
              module={SignbankWeb.CorpusExamples}
              id={"#{@sign.id}_corpus_examples"}
              gloss={@sign.id_gloss_annotation}
              version={:modal}
            />
            <div :if={Enum.count(@sign.suggested_signs) > 0} style="margin-top: 0.5em">
              <h2>Suggested signs</h2>
              <ul class="flex gap-2">
                <li :for={suggestion <- @sign.suggested_signs}>
                  <.modal id={"suggesed_sign_modal_#{suggestion.id}"}>
                    <video controls autoplay muted width="400">
                      <source src={"#{Application.fetch_env!(:signbank, :media_url)}/#{suggestion.url}"} />
                    </video>
                    <p :if={suggestion.description} class="mt-2">
                      {suggestion.description}
                    </p>
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

        <div>
          <%!-- TODO: add seealso/ant collapsible embeds here --%>
        </div>
      </Layouts.app>
      """
    else
      ~H"""
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <%= if @error do %>
          <%!-- TODO: this needs styling --%>
          <div class="prose lg:prose-xl">
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
        <% else %>
          <%= if not Enum.empty?(@inexact_matches) do %>
            <div>
              {Enum.count(@inexact_matches)} close matches found <hr />
              <ul class="keyword-disambig">
                <%= for {keyword, matches, any_published} <- Enum.sort_by(@inexact_matches, fn {kw, _matches, _any_published} -> String.downcase(kw) end) do %>
                  <li class={[
                    if(!any_published, do: "after:content-['*'] after:font-xl after:ml-[-0.2em]")
                  ]}>
                    <a
                      id={"#{keyword}__disambig_link"}
                      class="hover:underline cursor-pointer"
                      href={
                        ~p"/dictionary/sign/#{Enum.at(matches, 0)}?#{%{@query_params | "q" => keyword}}"
                      }
                      phx-click="disambiguate"
                      phx-value-keyword={keyword}
                    >
                      {keyword}
                    </a>
                  </li>
                <% end %>
              </ul>
            </div>
          <% end %>
        <% end %>
      </Layouts.app>
      """
    end
  end

  @impl true
  def handle_params(%{"id" => id_gloss} = params, _url, socket) do
    {:noreply,
     assign(
       socket,
       sign: load_sign(id_gloss, socket.assigns.current_scope)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> assign(:inexact_matches, [])

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
      socket =
        assign(
          socket,
          # TODO: check what the page title is/should be
          # page_title: page_title(socket.assigns.live_action),
          handshape: handshape,
          location: location,
          search_term: search_term,
          query_params: persist_query_params(params)
        )

      # TODO: we need to use `n` to get to a specific match number, but right now we can't
      # see other matches and they're not sorted properly anyway
      case Dictionary.fuzzy_find_keyword(search_term, socket.assigns.current_scope) do
        # if we match a keyword exactly, and its the only match, jump straight to results
        [{^search_term, matches, all_published}] ->
          socket =
            assign(
              socket,
              sign: Enum.at(matches, 0)
            )

          # TODO: figure out how to make this not redirect
          {:noreply,
           push_patch(socket,
             to: ~p"/dictionary/sign/#{Enum.at(matches, 0)}?#{%{"q" => search_term}}"
           )}

        [] ->
          {:noreply, assign(socket, :error, "No results found.")}

        inexact_matches ->
          {:noreply, assign(socket, :inexact_matches, inexact_matches)}
      end
    end
  end

  @impl true
  def handle_event("disambiguate", %{"keyword" => keyword}, socket) do
    {_kw, search_results, _all_published} =
      Enum.find(
        socket.assigns.inexact_matches,
        fn {kw, _signs, _all_published} ->
          kw == keyword
        end
      )

    # TODO: handle failure
    sign =
      Dictionary.get_sign_by_id_gloss(Enum.at(search_results, 0), socket.assigns.current_scope)

    # socket =
    #   assign(
    #     socket,
    #     # TODO: check what the page title is/should be
    #     # page_title: page_title(socket.assigns.live_action),
    #     sign: sign,
    #     search_results: search_results,
    #     search_term: keyword
    #   )

    {:noreply, socket}
  end

  def keyword_search(search_term, current_scope) do
    case Dictionary.fuzzy_find_keyword(search_term, current_scope) do
      # if we match a keyword exactly, and its the only match, jump straight to results
      [{^search_term, matches, _all_published}] ->
        {:ok, matches}

      [] ->
        {:ok, []}

      inexact_matches ->
        {:multiple, inexact_matches}
    end
  end

  def load_sign(id_gloss, current_scope) do
    case Dictionary.get_sign_by_id_gloss(id_gloss, current_scope) do
      %Dictionary.Sign{} = sign -> sign
      _ -> nil
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
          <%= for {%{text: keyword}, index} <- Enum.with_index(keywords, 1) do %>
            <span class={if keyword == @search_term, do: "font-bold"}>{keyword}</span><span :if={
              index < Enum.count(keywords)
            }>, </span>
          <% end %>
      <% end %>
    </p>
    """
  end

  defp search_results(assigns) do
    search_term = Map.get(assigns.query_params, "q")
    handshape = Map.get(assigns.query_params, "hs")
    location = Map.get(assigns.query_params, "loc")

    assigns =
      assign(assigns,
        search_term: search_term,
        handshape: handshape,
        location: location
      )

    ~H"""
    <div class="border-none flex flex-row justify-self-end justify-end items-center text-right">
      <div :if={assigns[:search_results] && not Enum.empty?(@search_results)} class="search-matches mr-2 md:mr-unset">
        <div phx-no-format>
          Matches
          <span :if={assigns[:search_term]}>for the word <i>{@search_term}</i></span><span :if={
            assigns[:handshape]
          }>with a {@handshape} handshape</span><span :if={assigns[:location]}> at {@location} location</span><%!--
          --%>:
        </div>
        <div class="input join gap-0 w-min p-0 border-none">
          <% len = Enum.count(@search_results) %>
          <% cur_i = (Enum.find_index(@search_results, &(&1 == @current)) || 0) + 1 %>
          <% lower_bound = min(cur_i - 2, len - 4) %>
          <% upper_bound = max(cur_i + 2, 5) %>
          <.search_result
            id_gloss={Enum.at(@search_results, 0)}
            query_params={@query_params}
            selected={cur_i}
            index={1}
          />
          <span class={[
            "join-item border-none btn btn-disabled",
            if(lower_bound <= 2, do: "hidden")
          ]}>
            &hellip;
          </span>
          <%= for i <- lower_bound..upper_bound do %>
            <.search_result
              :if={1 < i and i < len}
              id_gloss={@search_results |> Enum.at(i - 1)}
              query_params={@query_params}
              selected={cur_i}
              index={i}
            />
          <% end %>
          <span class={[
            "join-item border-none btn btn-disabled",
            if(upper_bound >= len - 1, do: "hidden")
          ]}>
            &hellip;
          </span>
          <.search_result
            :if={len > 1}
            id_gloss={Enum.at(@search_results, len - 1)}
            query_params={@query_params}
            selected={cur_i}
            index={len}
          />
        </div>
      </div>
    </div>
    """
  end

  defp search_result(assigns) do
    ~H"""
    <a
      id={"search_result_#{@id_gloss}"}
      class={"join-item border-none btn #{if @index == @selected do "bg-slate-300" end}"}
      href={~p"/dictionary/sign/#{@id_gloss}?#{@query_params}"}
    >
      {@index}
    </a>
    """
  end
end
