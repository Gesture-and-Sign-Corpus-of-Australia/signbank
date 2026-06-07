defmodule SignbankWeb.SignLive.PhonologicalSearch do
  use SignbankWeb, :live_view

  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  # TODO: while interacting with this page store selections in query params so you can go back to your selection
  @impl true
  def render(assigns) do
    # TODO: add optional keyword search here
    # TODO: add 'Search' button which is disabled if no filters are selected
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="is-size-3">Search by sign features</h1>
      <p>
        Find a sign by clicking on a <a href="#handshape">handshape</a>
        or <a href="#location">location</a>. You can select both a
        handshape and a location.
      </p>
      <p class="md:hidden font-bold">This functionality works best on a computer or tablet.</p>

      <hr />

      <form action="/dictionary" method="GET">
        <button class="btn">
          <.icon name="hero-magnifying-glass" /> Search
        </button>

        <input id="search-handshape-filter" type="hidden" name="hs" value={@selected_handshape} />
        <input id="search-location-filter" type="hidden" name="loc" value={@selected_location} />

        <h2 id="handshape" class="is-size-4">Handshape</h2>
        <.handshapes_allophones />

        <h2 id="location" class="is-size-4">Location</h2>
        <a phx-click="deselect" phx-value-filter={:location}>
          <.icon name="hero-x-mark" class="size-16 bg-black" />
        </a>
        <div class="level" style="height:80%;display:flex;">
          <.face class="location_filter_container" style="flex-basis: 60%" />
          <.body class="location_filter_container" style="flex-basis: 60%" />
        </div>

        <button class="btn">
          <.icon name="hero-magnifying-glass" class="size-4" /> Search
        </button>
      </form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(page_title: gettext("Search by feature"))
     |> assign(page: nil)
     |> assign(filter: "")
     |> assign(selected_location: "")
     |> assign(selected_handshape: "")}
  end

  @impl true
  def handle_event("search", %{"search_form" => params}, socket) do
    # {:noreply, search(socket, params)}
    {:noreply, socket, params}
  end

  def handle_event("filter", %{"location" => location}, socket) do
    {:noreply,
     socket
     |> assign(selected_location: location)
     |> push_event("phon-filter-highlight", %{location: location})}
  end

  def handle_event("filter", %{"handshape" => handshape}, socket) do
    {:noreply,
     socket
     |> assign(selected_handshape: handshape)
     |> push_event("phon-filter-highlight", %{handshape: handshape})}
  end

  def handle_event("deselect", %{"filter" => filter}, socket) do
    handle_event("filter", %{filter => nil}, socket)
  end

  def face(assigns) do
    ~H"""
    <svg
      {assigns}
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="0 0 800 1184"
    >
      <image width="800" height="1184" xlink:href="/images/locations_face.png"></image>
      <a tabindex="0" phx-click="filter" phx-value-location="top_head">
        <rect x="89" y="43" fill="#fff" opacity="0" width="638" height="163"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="forehead">
        <rect x="91" y="222" fill="#fff" opacity="0" width="638" height="163"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="temple">
        <rect x="40" y="340" fill="#fff" opacity="0" width="135" height="135"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="temple">
        <rect x="645" y="340" fill="#fff" opacity="0" width="135" height="135"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="eyes">
        <rect x="198" y="425" fill="#fff" opacity="0" width="432" height="125"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="ear_or_side_head">
        <rect x="61" y="501" fill="#fff" opacity="0" width="115" height="222"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="cheekbone">
        <rect x="202" y="574" fill="#fff" opacity="0" width="114" height="117"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="nose">
        <rect x="347" y="559" fill="#fff" opacity="0" width="127" height="159"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="cheekbone">
        <rect x="508" y="575" fill="#fff" opacity="0" width="116" height="117"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="ear_or_side_head">
        <rect x="650" y="499" fill="#fff" opacity="0" width="117" height="221"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="cheek">
        <rect x="190" y="709" fill="#fff" opacity="0" width="119" height="143"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="mouth_or_lips">
        <rect x="319" y="730" fill="#fff" opacity="0" width="188" height="97"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="cheek">
        <rect x="518" y="708" fill="#fff" opacity="0" width="118" height="142"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="chin">
        <rect x="310" y="869" fill="#fff" opacity="0" width="210" height="99"></rect>
      </a>
    </svg>
    """
  end

  def body(assigns) do
    ~H"""
    <svg
      {assigns}
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="0 0 800 800"
    >
      <image width="800" height="800" xlink:href="/images/locations_body.png"></image>
      <a tabindex="0" phx-click="filter" phx-value-location="whole_face">
        <rect x="165" y="37" fill="#fff" opacity="0" width="152" height="183"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="neck">
        <rect x="180" y="218" fill="#fff" opacity="0" width="121" height="50"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="shoulder">
        <rect x="97" y="252" fill="#fff" opacity="0" width="68" height="70"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="shoulder">
        <rect x="319" y="251" fill="#fff" opacity="0" width="68" height="70"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="chest">
        <rect x="171" y="264" fill="#fff" opacity="0" width="144" height="113"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="upper_arm">
        <rect x="95" y="326" fill="#fff" opacity="0" width="65" height="81"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="upper_arm">
        <rect x="323" y="324" fill="#fff" opacity="0" width="66" height="81"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="stomach">
        <rect x="171" y="383" fill="#fff" opacity="0" width="145" height="80"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="elbow">
        <rect x="84" y="415" fill="#fff" opacity="0" width="70" height="84"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="elbow">
        <rect x="328" y="413" fill="#fff" opacity="0" width="71" height="83"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="waist">
        <rect x="152" y="469" fill="#fff" opacity="0" width="178" height="89"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="supinated_forearm">
        <rect x="66" y="499" fill="#fff" opacity="0" width="69" height="78"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="pronated_forearm">
        <rect x="350" y="499" fill="#fff" opacity="0" width="71" height="74"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="supinated_wrist">
        <rect x="46" y="572" fill="#fff" opacity="0" width="77" height="50"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="pronated_wrist">
        <rect x="364" y="574" fill="#fff" opacity="0" width="80" height="50"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="below_waist">
        <rect x="132" y="570" fill="#fff" opacity="0" width="219" height="130"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="high_neutral_space">
        <rect x="663" y="38" fill="#fff" opacity="0" width="119" height="232"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="neutral_space">
        <rect x="663" y="279" fill="#fff" opacity="0" width="119" height="233"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="low_neutral_space">
        <rect x="663" y="516" fill="#fff" opacity="0" width="120" height="210"></rect>
      </a>
    </svg>
    """
  end

  def handshapes_allophones(assigns) do
    ~H"""
    <div id="handshapegrid" class="flex flex-auto flex-wrap">
      <a
        phx-click="deselect"
        class="h-auto cursor-pointer w-55 border-2 flex justify-center items-center"
        phx-value-filter={:handshape}
      >
        <.icon name="hero-x-mark" class="size-16 bg-black" />
      </a>
      <.handshapes_grid ref={:round} shapes={[:round, :round_flat, :round_flick, :round_e]} />
      <.handshapes_grid ref={:okay} shapes={[:okay, :okay_flat, :okay_f]} />
      <.handshapes_grid ref={:point} shapes={[:point, :point_d, :point_angled, :point_angled_thumb]} />
      <.handshapes_grid ref={:hook} shapes={[:hook, :hook_bent]} />
      <.handshapes_grid ref={:two} shapes={[:two, :two_angled]} />
      <.handshapes_grid ref={:kneel} shapes={[:kneel]} />
      <.handshapes_grid ref={:perth} shapes={[:perth]} />
      <.handshapes_grid ref={:spoon} shapes={[:spoon, :spoon_thumb, :spoon_curved]} />
      <.handshapes_grid ref={:letter_n} shapes={[:letter_n]} />
      <.handshapes_grid ref={:wish} shapes={[:wish]} />
      <.handshapes_grid ref={:three} shapes={[:three, :three_curved, :three_bent]} />
      <.handshapes_grid ref={:mother} shapes={[:mother]} />
      <.handshapes_grid ref={:letter_m} shapes={[:letter_m]} />
      <.handshapes_grid ref={:four} shapes={[:four, :four_curved]} />
      <.handshapes_grid ref={:five} shapes={[:five, :five_angled]} />
      <.handshapes_grid ref={:ball} shapes={[:ball, :ball_bent]} />
      <.handshapes_grid ref={:flat} shapes={[:flat, :flat_b, :flat_angled, :flat_b_angled]} />
      <.handshapes_grid ref={:thick} shapes={[:thick, :thick_open]} />
      <.handshapes_grid ref={:cup} shapes={[:cup, :cup_thumb, :cup_flush]} />
      <.handshapes_grid ref={:good} shapes={[:good, :good_bent]} />
      <.handshapes_grid ref={:bad} shapes={[:bad, :bad_bent]} />
      <.handshapes_grid ref={:gun} shapes={[:gun, :gun_bent]} />
      <.handshapes_grid ref={:buckle} shapes={[:buckle]} />
      <.handshapes_grid ref={:letter_c} shapes={[:letter_c, :letter_c_open]} />
      <.handshapes_grid ref={:small} shapes={[:small, :small_open]} />
      <.handshapes_grid ref={:seven_old} shapes={[:seven_old]} />
      <.handshapes_grid ref={:eight} shapes={[:eight, :eight_curved]} />
      <.handshapes_grid ref={:nine} shapes={[:nine]} />
      <.handshapes_grid ref={:fist} shapes={[:fist, :fist_a]} />
      <.handshapes_grid ref={:soon} shapes={[:soon, :soon_flick, :soon_closed]} />
      <.handshapes_grid ref={:ten} shapes={[:ten, :ten_tip, :ten_flat, :ten_tip_open]} />
      <.handshapes_grid ref={:write} shapes={[:write, :write_flat, :write_flick]} />
      <.handshapes_grid ref={:salt} shapes={[:salt, :salt_closed, :salt_flick]} />
      <.handshapes_grid ref={:duck} shapes={[:duck]} />
      <.handshapes_grid ref={:middle} shapes={[:middle]} />
      <.handshapes_grid ref={:rude} shapes={[:rude]} />
      <.handshapes_grid ref={:ambivalent} shapes={[:ambivalent]} />
      <.handshapes_grid ref={:love} shapes={[:love]} />
      <.handshapes_grid ref={:animal} shapes={[:animal, :animal_closed]} />
      <.handshapes_grid ref={:queer} shapes={[:queer]} />
    </div>
    """
  end

  attr :shapes, :list, required: true
  attr :ref, :atom, required: true

  def handshapes_grid(assigns) do
    ~H"""
    <a href={"##{@ref}"} class="flex" phx-click="filter" phx-value-handshape={@ref}>
      <div class="h-auto grid grid-cols-2 border-2 w-55">
        <%= for hs <- @shapes do %>
          <.handshape handshape={hs} />
        <% end %>
      </div>
    </a>
    """
  end

  defp handshape(assigns) do
    ~H"""
    <div>
      <img src={Dictionary.Phonology.handshape_image(@handshape)} />
    </div>
    """
  end
end
