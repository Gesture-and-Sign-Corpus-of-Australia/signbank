defmodule SignbankWeb.SignLive.PhonologicalSearch do
  use SignbankWeb, :live_view

  alias Signbank.Dictionary

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @handshape_groups [
    round: [:round, :round_flat, :round_flick, :round_e],
    okay: [:okay, :okay_flat, :okay_f],
    point: [:point, :point_d, :point_angled, :point_angled_thumb],
    hook: [:hook, :hook_bent],
    two: [:two, :two_angled],
    kneel: [:kneel],
    perth: [:perth],
    spoon: [:spoon, :spoon_thumb, :spoon_curved],
    letter_n: [:letter_n],
    wish: [:wish],
    three: [:three, :three_curved, :three_bent],
    mother: [:mother],
    letter_m: [:letter_m],
    four: [:four, :four_curved],
    five: [:five, :five_angled],
    ball: [:ball, :ball_bent],
    flat: [:flat, :flat_b, :flat_angled, :flat_b_angled],
    thick: [:thick, :thick_open],
    cup: [:cup, :cup_thumb, :cup_flush],
    good: [:good, :good_bent],
    bad: [:bad, :bad_bent],
    gun: [:gun, :gun_bent],
    buckle: [:buckle],
    letter_c: [:letter_c, :letter_c_open],
    small: [:small, :small_open],
    seven_old: [:seven_old],
    eight: [:eight, :eight_curved],
    nine: [:nine],
    fist: [:fist, :fist_a],
    soon: [:soon, :soon_flick, :soon_closed],
    ten: [:ten, :ten_tip, :ten_flat, :ten_tip_open],
    write: [:write, :write_flat, :write_flick],
    salt: [:salt, :salt_closed, :salt_flick],
    duck: [:duck],
    middle: [:middle],
    rude: [:rude],
    ambivalent: [:ambivalent],
    love: [:love],
    animal: [:animal, :animal_closed],
    queer: [:queer]
  ]

  @handshape_page_size 28

  # TODO: while interacting with this page store selections in query params so you can go back to your selection
  @impl true
  def render(assigns) do
    # TODO: add optional keyword search here
    assigns =
      assigns
      |> assign(:filter_count, filter_count(assigns))
      |> assign(:handshape_groups, visible_handshape_groups(assigns))
      |> assign(:more_handshapes?, assigns.hs_limit < length(@handshape_groups))

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} wide>
      <form action="/dictionary" method="GET">
        <header class="mb-8">
          <h1 class="text-2xl font-bold">{gettext("Search by Sign Features")}</h1>
          <p class="text-base text-base-content/70">
            {gettext(
              "Find a sign by selecting a handshape, a location, or both, then select Search Signs."
            )}
          </p>

          <button
            type="submit"
            class="btn mt-4 border-0 bg-purple text-base text-white hover:bg-purple/85 disabled:bg-purple/40 disabled:text-white"
            disabled={@filter_count == 0}
          >
            <.icon name="hero-magnifying-glass" class="size-4" />
            {gettext("Search Signs")}
            <span
              :if={@filter_count > 0}
              class="badge badge-sm border-0 bg-white/30 text-white"
              aria-label={gettext("%{count} selected", count: @filter_count)}
            >
              {@filter_count}
            </span>
          </button>
        </header>


        <input id="search-handshape-filter" type="hidden" name="hs" value={@selected_handshape}
          disabled={@selected_handshape in [nil, ""]} />
        <input id="search-location-filter" type="hidden" name="loc" value={@selected_location}
          disabled={@selected_location in [nil, ""]} />

        <div class="grid grid-cols-1 gap-8 lg:grid-cols-3">
          <section id="handshape" class="lg:col-span-2" aria-labelledby="handshape-heading">
            <.section_header
              id="handshape-heading"
              title={gettext("Handshapes")}
              subtitle={gettext("Select a handshape to filter the signs")}
              filter="handshape"
              disabled={@selected_handshape in [nil, ""]}
            />

            <.handshape_bold_filter />

            <div id="handshapegrid" class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
              <.handshape_card
                :for={{ref, shapes} <- @handshape_groups}
                ref={ref}
                shapes={shapes}
                selected={to_string(ref) == @selected_handshape}
              />
            </div>

            <button
              :if={@more_handshapes?}
              type="button"
              phx-click="load_more"
              class="btn btn-ghost btn-md mt-4 px-4 text-base font-normal"
            >
              <.icon name="hero-chevron-down" class="size-5" />
              {gettext("Load More")}
            </button>
          </section>

          <section
            id="location"
            class="lg:border-l lg:border-base-300 lg:pl-8"
            aria-labelledby="location-heading"
          >
            <.section_header
              id="location-heading"
              title={gettext("Location")}
              subtitle={gettext("Select where the sign is made")}
              filter="location"
              disabled={@selected_location in [nil, ""]}
            />

            <div class="location_filter_container flex flex-col items-center gap-6 bg-base-200/50 p-4">
              <.face selected={@selected_location} class="w-full max-w-xs" />
              <.body_front selected={@selected_location} class="w-full max-w-xs" />
              <.body_side selected={@selected_location} class="w-2/3 max-w-[13rem]" />
            </div>
          </section>
        </div>
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
     |> assign(hs_limit: @handshape_page_size)
     |> assign(selected_location: "")
     |> assign(selected_handshape: "")}
  end

  # Clicking the selected item again deselects it.
  @impl true
  def handle_event("filter", %{"location" => location}, socket) do
    {:noreply, assign(socket, selected_location: toggle(socket.assigns.selected_location, location))}
  end

  def handle_event("filter", %{"handshape" => handshape}, socket) do
    {:noreply,
     assign(socket, selected_handshape: toggle(socket.assigns.selected_handshape, handshape))}
  end

  def handle_event("deselect", %{"filter" => "location"}, socket) do
    {:noreply, assign(socket, selected_location: "")}
  end

  def handle_event("deselect", %{"filter" => "handshape"}, socket) do
    {:noreply, assign(socket, selected_handshape: "")}
  end

  def handle_event("load_more", _params, socket) do
    {:noreply, update(socket, :hs_limit, &(&1 + @handshape_page_size))}
  end

  defp toggle(current, current), do: ""
  defp toggle(_current, new), do: new

  defp filter_count(assigns) do
    Enum.count([assigns.selected_handshape, assigns.selected_location], &(&1 not in [nil, ""]))
  end

  # Always show the selected group, even if it sits past the current page.
  defp visible_handshape_groups(%{hs_limit: limit, selected_handshape: selected}) do
    {visible, hidden} = Enum.split(@handshape_groups, limit)

    case Enum.find(hidden, fn {ref, _} -> to_string(ref) == selected end) do
      nil -> visible
      group -> visible ++ [group]
    end
  end

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  attr :filter, :string, required: true
  attr :disabled, :boolean, default: false

  defp section_header(assigns) do
    ~H"""
    <div class="mb-4 flex items-start justify-between gap-4">
      <div>
        <h2 id={@id} class="text-lg font-bold">{@title}</h2>
        <p class="text-base text-base-content/70">{@subtitle}</p>
      </div>
      <button
        type="button"
        phx-click="deselect"
        phx-value-filter={@filter}
        class="btn btn-sm btn-outline border-base-300 px-3 text-sm font-normal"
        disabled={@disabled}
        aria-label={gettext("Clear %{title} selection", title: String.downcase(@title))}
      >
        <.icon name="hero-x-mark" class="size-4" />
        {gettext("Clear")}
      </button>
    </div>
    """
  end

  attr :ref, :atom, required: true
  attr :shapes, :list, required: true
  attr :selected, :boolean, default: false

  # SVG filter used by .handshape-stem to make every line of the stem/phoneme drawing bolder
  defp handshape_bold_filter(assigns) do
    ~H"""
    <svg width="0" height="0" class="absolute" aria-hidden="true" focusable="false">
      <filter id="handshape-bold" color-interpolation-filters="sRGB">
        <feFlood flood-color="#fff" result="white" />
        <feComposite in="SourceGraphic" in2="white" operator="over" result="flat" />
        <feComponentTransfer in="flat" result="dark">
          <feFuncR type="gamma" exponent="1.8" />
          <feFuncG type="gamma" exponent="1.8" />
          <feFuncB type="gamma" exponent="1.8" />
        </feComponentTransfer>
        <feMorphology in="dark" operator="erode" radius="0.5" />
      </filter>
    </svg>
    """
  end

  defp handshape_card(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="filter"
      phx-value-handshape={@ref}
      aria-pressed={to_string(@selected)}
      aria-label={Phoenix.Naming.humanize(@ref)}
      class={[
        "grid aspect-square w-full cursor-pointer gap-1 overflow-hidden rounded-xl border p-2 transition",
        "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-purple",
        if(length(@shapes) == 1,
          do: "grid-cols-1 grid-rows-1",
          else: "grid-cols-2 grid-rows-2"
        ),
        if(@selected,
          do: "border-purple bg-[oklch(78%_0.07_295/0.85)] ring-2 ring-purple",
          else: "border-base-300 bg-white hover:border-purple/50 hover:shadow-sm"
        )
      ]}
    >
      <img
        :for={hs <- @shapes}
        src={Dictionary.Phonology.handshape_image(hs)}
        alt=""
        class={[
          "h-full min-h-0 w-full min-w-0 object-contain mix-blend-multiply",
          # The group's ref is its stem/phoneme; emphasise it over the allophones
          length(@shapes) > 1 &&
            if(hs == @ref, do: "handshape-stem", else: "handshape-allophone")
        ]}
        loading="lazy"
      />
    </button>
    """
  end

  # One clickable region on a location diagram.
  attr :location, :string, required: true
  attr :selected, :string, required: true
  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :width, :integer, required: true
  attr :height, :integer, required: true
  attr :focusable, :boolean, default: true

  defp region(assigns) do
    ~H"""
    <g
      class="loc-region"
      role="button"
      tabindex={if @focusable, do: "0", else: "-1"}
      aria-hidden={if @focusable, do: nil, else: "true"}
      aria-label={Phoenix.Naming.humanize(@location)}
      aria-pressed={to_string(@selected == @location)}
      phx-click="filter"
      phx-keydown="filter"
      phx-key="Enter"
      phx-value-location={@location}
    >
      <rect x={@x} y={@y} width={@width} height={@height} rx="8"></rect>
    </g>
    """
  end

  # Face view
  attr :selected, :string, required: true
  attr :rest, :global

  def face(assigns) do
    ~H"""
    <svg
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="0 0 800 1184"
      aria-label={gettext("Face locations")}
      {@rest}
    >
      <image width="800" height="1184" xlink:href="/images/locations_face.png"></image>
      <.region selected={@selected} location="top_head" x={89} y={43} width={638} height={163} />
      <.region selected={@selected} location="forehead" x={91} y={222} width={638} height={163} />
      <.region selected={@selected} location="temple" x={40} y={340} width={135} height={135} />
      <.region selected={@selected} location="temple" x={645} y={340} width={135} height={135} focusable={false} />
      <.region selected={@selected} location="eyes" x={198} y={425} width={432} height={125} />
      <.region selected={@selected} location="ear_or_side_head" x={61} y={501} width={115} height={222} />
      <.region selected={@selected} location="cheekbone" x={202} y={574} width={114} height={117} />
      <.region selected={@selected} location="nose" x={347} y={559} width={127} height={159} />
      <.region selected={@selected} location="cheekbone" x={508} y={575} width={116} height={117} focusable={false} />
      <.region selected={@selected} location="ear_or_side_head" x={650} y={499} width={117} height={221} focusable={false} />
      <.region selected={@selected} location="cheek" x={190} y={709} width={119} height={143} />
      <.region selected={@selected} location="mouth_or_lips" x={319} y={730} width={188} height={97} />
      <.region selected={@selected} location="cheek" x={518} y={708} width={118} height={142} focusable={false} />
      <.region selected={@selected} location="chin" x={310} y={869} width={210} height={99} />
    </svg>
    """
  end

  # Front view
  attr :selected, :string, required: true
  attr :rest, :global

  def body_front(assigns) do
    ~H"""
    <svg
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="0 20 460 720"
      aria-label={gettext("Body locations")}
      {@rest}
    >
      <image width="800" height="800" xlink:href="/images/locations_body.png"></image>
      <.region selected={@selected} location="whole_face" x={165} y={37} width={152} height={183} />
      <.region selected={@selected} location="neck" x={180} y={218} width={121} height={50} />
      <.region selected={@selected} location="shoulder" x={97} y={252} width={68} height={70} />
      <.region selected={@selected} location="shoulder" x={319} y={251} width={68} height={70} focusable={false} />
      <.region selected={@selected} location="chest" x={171} y={264} width={144} height={113} />
      <.region selected={@selected} location="upper_arm" x={95} y={326} width={65} height={81} />
      <.region selected={@selected} location="upper_arm" x={323} y={324} width={66} height={81} focusable={false} />
      <.region selected={@selected} location="stomach" x={171} y={383} width={145} height={80} />
      <.region selected={@selected} location="elbow" x={84} y={415} width={70} height={84} />
      <.region selected={@selected} location="elbow" x={328} y={413} width={71} height={83} focusable={false} />
      <.region selected={@selected} location="waist" x={152} y={469} width={178} height={89} />
      <.region selected={@selected} location="supinated_forearm" x={66} y={499} width={69} height={78} />
      <.region selected={@selected} location="pronated_forearm" x={350} y={499} width={71} height={74} />
      <.region selected={@selected} location="supinated_wrist" x={46} y={572} width={77} height={50} />
      <.region selected={@selected} location="pronated_wrist" x={364} y={574} width={80} height={50} />
      <.region selected={@selected} location="below_waist" x={132} y={570} width={219} height={130} />
    </svg>
    """
  end

  # Side view
  attr :selected, :string, required: true
  attr :rest, :global

  def body_side(assigns) do
    ~H"""
    <svg
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="480 20 315 720"
      aria-label={gettext("Signing space locations")}
      {@rest}
    >
      <image width="800" height="800" xlink:href="/images/locations_body.png"></image>
      <.region selected={@selected} location="high_neutral_space" x={663} y={38} width={119} height={232} />
      <.region selected={@selected} location="neutral_space" x={663} y={279} width={119} height={233} />
      <.region selected={@selected} location="low_neutral_space" x={663} y={516} width={120} height={210} />
    </svg>
    """
  end
end
