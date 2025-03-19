defmodule SignbankWeb.SignLive.PhonologicalSearch do
  use SignbankWeb, :live_view

  alias Signbank.Dictionary
  alias SignbankWeb.Search.SearchForm

  on_mount {SignbankWeb.UserAuth, :mount_current_user}

  @impl true
  def render(assigns) do
    # TODO: add optional keyword search here
    # TODO: add 'Search' button which is disabled if no filters are selected
    ~H"""
    <form action="/dictionary" method="GET">
      <div class="field has-addons">
        <input
          class="input"
          type="text"
          name="q"
          placeholder={gettext("Filter by keyword (optional)...")}
        />
        <input id="search-handshape-filter" type="hidden" name="hs" value={@selected_handshape} />
        <input id="search-location-filter" type="hidden" name="loc" value={@selected_location} />
        <button class="button">
          <Heroicons.magnifying_glass class="icon--medium zzicon--small" />
        </button>
      </div>
    </form>

    <h1>Handshape</h1>
    <.handshapes />
    <h1>Location</h1>
    <div class="level" style="height:80%;display:flex;">
      <.face class="location_filter_container" style="flex-basis: 60%" />
      <.body class="location_filter_container" />
    </div>
    <%!-- TODO: make these links the same as the imagemap ones --%>
    <%!-- <div class="level">
      top_head
      forehead
      temple
      eye
      cheekbone
      nose
      whole_face
      ear_or_side_head
      cheek
      mouth_or_lips
      chin
      neck
      shoulder
      high_neutral_space
      chest
      neutral_space
      stomach
      low_neutral_space
      waist
      below_waist
      upper_arm
      elbow
      pronated_forearm
      supinated_forearm
      pronated_wrist
      supinated_wrist
    </div>
    --%>
    """
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
      <a tabindex="0" phx-click="filter" phx-value-location="top_head" data-xlink:href="#top_head">
        <rect x="89" y="43" fill="#fff" opacity="0" width="638" height="163"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="forehead" data-xlink:href="#forehead">
        <rect x="91" y="222" fill="#fff" opacity="0" width="638" height="163"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="eyes" data-xlink:href="#eyes">
        <rect x="198" y="425" fill="#fff" opacity="0" width="432" height="125"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="ear_or_side_head"
        data-xlink:href="#ear_or_side_head"
      >
        <rect x="61" y="501" fill="#fff" opacity="0" width="115" height="222"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="cheekbone" data-xlink:href="#cheekbone">
        <rect x="202" y="574" fill="#fff" opacity="0" width="114" height="117"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="nose" data-xlink:href="#nose">
        <rect x="347" y="559" fill="#fff" opacity="0" width="127" height="159"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="cheekbone" data-xlink:href="#cheekbone">
        <rect x="508" y="575" fill="#fff" opacity="0" width="116" height="117"></rect>
      </a>
      <a
        tabindex="-1"
        phx-click="filter"
        phx-value-location="ear_or_side_head"
        data-xlink:href="#ear_or_side_head"
      >
        <rect x="650" y="499" fill="#fff" opacity="0" width="117" height="221"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="cheek" data-xlink:href="#cheek">
        <rect x="190" y="709" fill="#fff" opacity="0" width="119" height="143"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="mouth_or_lips"
        data-xlink:href="#mouth_or_lips"
      >
        <rect x="319" y="730" fill="#fff" opacity="0" width="188" height="97"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="cheek" data-xlink:href="#cheek">
        <rect x="518" y="708" fill="#fff" opacity="0" width="118" height="142"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="chin" data-xlink:href="#chin">
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
      <a tabindex="0" phx-click="filter" phx-value-location="whole_face" xlink:href="#whole_face">
        <rect x="165" y="37" fill="#fff" opacity="0" width="152" height="183"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="neck" data-xlink:href="#neck">
        <rect x="180" y="218" fill="#fff" opacity="0" width="121" height="50"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="shoulder" data-xlink:href="#shoulder">
        <rect x="97" y="252" fill="#fff" opacity="0" width="68" height="70"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="shoulder" data-xlink:href="#shoulder">
        <rect x="319" y="251" fill="#fff" opacity="0" width="68" height="70"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="chest" data-xlink:href="#chest">
        <rect x="171" y="264" fill="#fff" opacity="0" width="144" height="113"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="upper_arm" data-xlink:href="#upper_arm">
        <rect x="95" y="326" fill="#fff" opacity="0" width="65" height="81"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="upper_arm" data-xlink:href="#upper_arm">
        <rect x="323" y="324" fill="#fff" opacity="0" width="66" height="81"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="stomach" data-xlink:href="#stomach">
        <rect x="171" y="383" fill="#fff" opacity="0" width="145" height="80"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="elbow" data-xlink:href="#elbow">
        <rect x="84" y="415" fill="#fff" opacity="0" width="70" height="84"></rect>
      </a>
      <a tabindex="-1" phx-click="filter" phx-value-location="elbow" data-xlink:href="#elbow">
        <rect x="328" y="413" fill="#fff" opacity="0" width="71" height="83"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="waist" data-xlink:href="#waist">
        <rect x="152" y="469" fill="#fff" opacity="0" width="178" height="89"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="supinated_forearm"
        data-xlink:href="#supinated_forearm"
      >
        <rect x="66" y="499" fill="#fff" opacity="0" width="69" height="78"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="pronated_forearm"
        data-xlink:href="#pronated_forearm"
      >
        <rect x="350" y="499" fill="#fff" opacity="0" width="71" height="74"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="supinated_wrist"
        data-xlink:href="#supinated_wrist"
      >
        <rect x="46" y="572" fill="#fff" opacity="0" width="77" height="50"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="pronated_wrist"
        data-xlink:href="#pronated_wrist"
      >
        <rect x="364" y="574" fill="#fff" opacity="0" width="80" height="50"></rect>
      </a>
      <a tabindex="0" phx-click="filter" phx-value-location="below" data-xlink:href="#below-waist">
        <rect x="132" y="570" fill="#fff" opacity="0" width="219" height="130"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="high_neutral_space"
        data-xlink:href="#high_neutral_space"
      >
        <rect x="663" y="38" fill="#fff" opacity="0" width="119" height="232"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="neutral_space"
        data-xlink:href="#neutral_space"
      >
        <rect x="663" y="279" fill="#fff" opacity="0" width="119" height="233"></rect>
      </a>
      <a
        tabindex="0"
        phx-click="filter"
        phx-value-location="low_neutral_space"
        data-xlink:href="#low_neutral_space"
      >
        <rect x="663" y="516" fill="#fff" opacity="0" width="120" height="210"></rect>
      </a>
    </svg>
    """
  end

  def handshapes(assigns) do
    ~H"""
    <style>
      #handshapegrid {
      display:flex;
      width: 70%;
      flex-wrap: wrap;
      gap: 2px;
      }
      #handshapegrid * {
      margin: 0.2em;
      flex: 0 1 14%;
      }
    </style>
    <div id="handshapegrid">
      <%!-- TODO: relaxed is not a handshape per-se, but we should have a "none" button to unselect handshape --%>
      <.handshape handshape={:relaxed} />
      <.handshape handshape={:round} />
      <.handshape handshape={:okay} />
      <.handshape handshape={:point} />
      <.handshape handshape={:hook} />
      <.handshape handshape={:two} />
      <.handshape handshape={:kneel} />
      <.handshape handshape={:perth} />
      <.handshape handshape={:spoon} />
      <.handshape handshape={:letter_n} />
      <.handshape handshape={:wish} />
      <.handshape handshape={:three} />
      <.handshape handshape={:mother} />
      <.handshape handshape={:letter_m} />
      <.handshape handshape={:four} />
      <.handshape handshape={:five} />
      <.handshape handshape={:ball} />
      <.handshape handshape={:flat} />
      <.handshape handshape={:thick} />
      <.handshape handshape={:cup} />
      <.handshape handshape={:good} />
      <.handshape handshape={:bad} />
      <.handshape handshape={:gun} />
      <.handshape handshape={:buckle} />
      <.handshape handshape={:letter_c} />
      <.handshape handshape={:small} />
      <.handshape handshape={:seven_old} />
      <.handshape handshape={:eight} />
      <.handshape handshape={:nine} />
      <%!-- TODO: check the database for instances of :fist; I think its been renamed; <.handshape handshape={:fist} /> --%>
      <.handshape handshape={:soon} />
      <.handshape handshape={:ten} />
      <.handshape handshape={:write} />
      <.handshape handshape={:salt} />
      <.handshape handshape={:duck} />
      <.handshape handshape={:middle} />
      <.handshape handshape={:rude} />
      <.handshape handshape={:ambivalent} />
      <.handshape handshape={:love} />
      <.handshape handshape={:animal} />
      <.handshape handshape={:queer} />
    </div>
    """
  end

  defp handshape(assigns) do
    # TODO: add small allophone images
    ~H"""
    <a href={"##{@handshape}"} phx-click="filter" phx-value-handshape={@handshape}>
      <img src={Dictionary.Phonology.handshape_image(@handshape)} />
    </a>
    """
  end

  @impl true
  def mount(_, _, socket) do
    # page =
    #   Dictionary.list_signs(socket.assigns.current_user, 1, %SignbankWeb.Search.SearchForm{
    #     filters: [%{field: "nil"}]
    #   })

    {:ok,
     socket
     # |> init_filters()
     # |> assign(page_title: gettext("Search signs"))
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
    # TODO: actually handle filter selection; perhaps highlight one of the regions
    socket =
      socket
      |> assign(selected_location: location)
      |> push_event("phon-filter-highlight", %{location: location})

    {:noreply, socket}
  end

  def handle_event("filter", %{"handshape" => handshape}, socket) do
    # TODO: actually handle filter selection; perhaps highlight one of the regions
    socket =
      socket
      |> assign(selected_handshape: handshape)
      |> push_event("phon-filter-highlight", %{handshape: handshape})

    {:noreply, socket}
  end
end
