defmodule SignbankWeb.GrammarLive do
  use SignbankWeb, :live_view

  on_mount {SignbankWeb.UserAuth, :mount_current_scope}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       chapters: ["Select a chapter"] ++ Keyword.keys(examples()),
       examples: ["Select a chapter": nil],
       example: nil,
       chapter: nil
     )}
  end

  @impl true
  def render(assigns) do
    assigns =
      if assigns.example == "Select an example", do: assign(assigns, example: nil), else: assigns

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="content">
        <h2>Grammar: supplementary data</h2>

        <p>
          Below you will find video clips of all the glossed (written) Auslan examples found in the book:
        </p>

        <p style="padding: 0 2em;text-indent:-2em">
          Johnston, T., & Schembri, A. (2007). <cite>Australian Sign Language (Auslan): An
        introduction to sign language linguistics</cite>. Cambridge: Cambridge University Press.
        </p>

        <p>
          This book introduces the structure of Auslan and other signed languages (its
          vocabulary and its grammar) to students of language and general linguistics.
        </p>

        <p>
          It also provides learners of Auslan with accessible information about how signs are made
          (phonology and morphology), what the different types of signs found in the language are
          (fixed and productive vocabulary, as well as gesture), and the way signs are put together
          to make sentences and tell stories (grammar and discourse).
        </p>

        <p>
          These videos were produced by <a href="https://www.deafconnected.com.au/">deafConnectEd</a>
          (Melbourne Polytechnic) with support by the
          Victorian Government, and build on earlier work by Della Goswell (Macquarie University).
        </p>
      </div>

      <.form for={%{}} phx-change="select-example" style="display:flex;">
        <.input type="select" name="chapter" options={@chapters} value={@chapter} />
        <.input :if={@chapter} type="select" name="example" options={@examples} value={@example} />
      </.form>

      <div
        class="video-container"
        style="display:flex;align-items:center;justify-content:center;background:black;width:100%;aspect-ratio:16/9;"
      >
        <p :if={is_nil(@example)} style="color:white;">No example selected.</p>
        <video :if={@example} id={@example} controls muted autoplay style="width:100%;">
          <source src={
            examples()[String.to_existing_atom(@chapter)][String.to_existing_atom(@example)][:url]
            |> url_patch()
          } />
        </video>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("select-example", %{"_target" => ["example"], "example" => example}, socket) do
    {:noreply,
     assign(
       socket,
       example: example
     )}
  end

  @impl true
  def handle_event("select-example", %{"_target" => ["chapter"], "chapter" => chapter}, socket) do
    {:noreply,
     assign(
       socket,
       chapter: chapter,
       example: nil,
       examples:
         (["Select an example": nil] ++ examples()[String.to_existing_atom(chapter)])
         |> Keyword.keys()
     )}
  end

  def url_patch(url) do
    [_, chapter, example] = String.split(url, "/", trim: true)

    Path.join([
      "https://media.auslan.org.au/mp4video/auslan_staging_py3/grammar-videos/Base",
      chapter,
      example
    ])
  end

  def examples do
    [
      "Chapter 4": [
        "4.1": %{
          page: "115",
          url: "/grammar-videos/4./4.1.mp4"
        },
        "4.2": %{
          page: "115",
          url: "/grammar-videos/4./4.2.mp4"
        }
      ],
      "Chapter 5": [
        "5.1": %{
          page: "144",
          url: "/grammar-videos/5./5.1.mp4"
        },
        "5.2": %{
          page: "145",
          url: "/grammar-videos/5./5.2.mp4"
        },
        "5.3": %{
          page: "145",
          url: "/grammar-videos/5./5.3.mp4"
        },
        "5.4": %{
          page: "146",
          url: "/grammar-videos/5./5.4.mp4"
        },
        "5.5": %{
          page: "147",
          url: "/grammar-videos/5./5.5.mp4"
        },
        "5.7a": %{
          page: "149",
          url: "/grammar-videos/5./5.7a.mp4"
        },
        "5.7b": %{
          page: "149",
          url: "/grammar-videos/5./5.7b.mp4"
        },
        "5.7c": %{
          page: "149",
          url: "/grammar-videos/5./5.7c.mp4"
        },
        "5.8": %{
          page: "150",
          url: "/grammar-videos/5./5.8.mp4"
        },
        "5.9": %{
          page: "150",
          url: "/grammar-videos/5./5.9.mp4"
        },
        "5.10": %{
          page: "150",
          url: "/grammar-videos/5./5.10.mp4"
        },
        "5.11": %{
          page: "150",
          url: "/grammar-videos/5./5.11.mp4"
        },
        "5.12": %{
          page: "150",
          url: "/grammar-videos/5./5.12.mp4"
        },
        "5.13": %{
          page: "151",
          url: "/grammar-videos/5./5.13.mp4"
        },
        "5.14": %{
          page: "151",
          url: "/grammar-videos/5./5.14.mp4"
        },
        "5.15": %{
          page: "153",
          url: "/grammar-videos/5./5.15.mp4"
        },
        "5.16": %{
          page: "153",
          url: "/grammar-videos/5./5.16.mp4"
        },
        "5.17": %{
          page: "153",
          url: "/grammar-videos/5./5.17.mp4"
        }
      ],
      "Chapter 6": [
        "6.1": %{
          page: "158",
          url: "/grammar-videos/6./6.1.mp4"
        },
        "6.2": %{
          page: "167",
          url: "/grammar-videos/6./6.2.mp4"
        },
        "6.3": %{
          page: "167",
          url: "/grammar-videos/6./6.3.mp4"
        },
        "6.4": %{
          page: "167",
          url: "/grammar-videos/6./6.4.mp4"
        },
        "6.5": %{
          page: "168",
          url: "/grammar-videos/6./6.5.mp4"
        },
        "6.6": %{
          page: "168",
          url: "/grammar-videos/6./6.6.mp4"
        }
      ],
      "Chapter 7": [
        "7.1": %{
          page: "191",
          url: "/grammar-videos/7./7.1.mp4"
        },
        "7.2": %{
          page: "191",
          url: "/grammar-videos/7./7.2.mp4"
        },
        "7.3": %{
          page: "191",
          url: "/grammar-videos/7./7.3.mp4"
        },
        "7.4": %{
          page: "191",
          url: "/grammar-videos/7./7.4.mp4"
        },
        "7.5": %{
          page: "192",
          url: "/grammar-videos/7./7.5.mp4"
        },
        "7.6": %{
          page: "192",
          url: "/grammar-videos/7./7.6.mp4"
        },
        "7.7": %{
          page: "192",
          url: "/grammar-videos/7./7.7.mp4"
        },
        "7.8": %{
          page: "192",
          url: "/grammar-videos/7./7.8.mp4"
        },
        "7.9": %{
          page: "192",
          url: "/grammar-videos/7./7.9.mp4"
        },
        "7.10": %{
          page: "193",
          url: "/grammar-videos/7./7.10.mp4"
        },
        "7.11": %{
          page: "193",
          url: "/grammar-videos/7./7.11.mp4"
        },
        "7.13": %{
          page: "194",
          url: "/grammar-videos/7./7.13.mp4"
        },
        "7.14": %{
          page: "194",
          url: "/grammar-videos/7./7.14.mp4"
        },
        "7.15": %{
          page: "194",
          url: "/grammar-videos/7./7.15.mp4"
        },
        "7.16": %{
          page: "194",
          url: "/grammar-videos/7./7.16.mp4"
        },
        "7.17": %{
          page: "194",
          url: "/grammar-videos/7./7.17.mp4"
        },
        "7.18": %{
          page: "",
          url: "/grammar-videos/7./7.18.mp4"
        },
        "7.19": %{
          page: "195",
          url: "/grammar-videos/7./7.19.mp4"
        },
        "7.20": %{
          page: "195",
          url: "/grammar-videos/7./7.20.mp4"
        },
        "7.21": %{
          page: "195",
          url: "/grammar-videos/7./7.21.mp4"
        },
        "7.22": %{
          page: "196",
          url: "/grammar-videos/7./7.22.mp4"
        },
        "7.23": %{
          page: "197",
          url: "/grammar-videos/7./7.23.mp4"
        },
        "7.24": %{
          page: "197",
          url: "/grammar-videos/7./7.24.mp4"
        },
        "7.25": %{
          page: "198",
          url: "/grammar-videos/7./7.25.mp4"
        },
        "7.26": %{
          page: "198",
          url: "/grammar-videos/7./7.26.mp4"
        },
        "7.27": %{
          page: "198",
          url: "/grammar-videos/7./7.27.mp4"
        },
        "7.28": %{
          page: "198",
          url: "/grammar-videos/7./7.28.mp4"
        },
        "7.29": %{
          page: "198",
          url: "/grammar-videos/7./7.29.mp4"
        },
        "7.30": %{
          page: "199",
          url: "/grammar-videos/7./7.30.mp4"
        },
        "7.31": %{
          page: "200",
          url: "/grammar-videos/7./7.31.mp4"
        },
        "7.32": %{
          page: "200",
          url: "/grammar-videos/7./7.32.mp4"
        },
        "7.33": %{
          page: "200",
          url: "/grammar-videos/7./7.33.mp4"
        },
        "7.34": %{
          page: "201",
          url: "/grammar-videos/7./7.34.mp4"
        },
        "7.35": %{
          page: "201",
          url: "/grammar-videos/7./7.35.mp4"
        },
        "7.36": %{
          page: "202",
          url: "/grammar-videos/7./7.36.mp4"
        },
        "7.37": %{
          page: "202",
          url: "/grammar-videos/7./7.37.mp4"
        },
        "7.38": %{
          page: "202",
          url: "/grammar-videos/7./7.38.mp4"
        },
        "7.39": %{
          page: "203",
          url: "/grammar-videos/7./7.39.mp4"
        },
        "7.40": %{
          page: "203",
          url: "/grammar-videos/7./7.40.mp4"
        },
        "7.41": %{
          page: "203",
          url: "/grammar-videos/7./7.41.mp4"
        },
        "7.42": %{
          page: "203",
          url: "/grammar-videos/7./7.42.mp4"
        },
        "7.43": %{
          page: "203",
          url: "/grammar-videos/7./7.43.mp4"
        },
        "7.44": %{
          page: "203",
          url: "/grammar-videos/7./7.44.mp4"
        },
        "7.45": %{
          page: "203",
          url: "/grammar-videos/7./7.45.mp4"
        },
        "7.46": %{
          page: "204",
          url: "/grammar-videos/7./7.46.mp4"
        },
        "7.47": %{
          page: "204",
          url: "/grammar-videos/7./7.47.mp4"
        },
        "7.48": %{
          page: "204",
          url: "/grammar-videos/7./7.48.mp4"
        },
        "7.49": %{
          page: "204",
          url: "/grammar-videos/7./7.49.mp4"
        },
        "7.50": %{
          page: "204",
          url: "/grammar-videos/7./7.50.mp4"
        },
        "7.51": %{
          page: "205",
          url: "/grammar-videos/7./7.51.mp4"
        },
        "7.52": %{
          page: "205",
          url: "/grammar-videos/7./7.52.mp4"
        },
        "7.53": %{
          page: "205",
          url: "/grammar-videos/7./7.53.mp4"
        },
        "7.54": %{
          page: "205",
          url: "/grammar-videos/7./7.54.mp4"
        },
        "7.55": %{
          page: "205",
          url: "/grammar-videos/7./7.55.mp4"
        },
        "7.56": %{
          page: "206",
          url: "/grammar-videos/7./7.56.mp4"
        },
        "7.57": %{
          page: "206",
          url: "/grammar-videos/7./7.57.mp4"
        },
        "7.58": %{
          page: "206",
          url: "/grammar-videos/7./7.58.mp4"
        },
        "7.59": %{
          page: "206",
          url: "/grammar-videos/7./7.59.mp4"
        },
        "7.60": %{
          page: "206",
          url: "/grammar-videos/7./7.60.mp4"
        },
        "7.61": %{
          page: "207",
          url: "/grammar-videos/7./7.61.mp4"
        },
        "7.62": %{
          page: "207",
          url: "/grammar-videos/7./7.62.mp4"
        },
        "7.63": %{
          page: "208",
          url: "/grammar-videos/7./7.63.mp4"
        },
        "7.64a": %{
          page: "208",
          url: "/grammar-videos/7./7.64a.mp4"
        },
        "7.64b": %{
          page: "208",
          url: "/grammar-videos/7./7.64b.mp4"
        },
        "7.65": %{
          page: "208",
          url: "/grammar-videos/7./7.65.mp4"
        },
        "7.66": %{
          page: "209",
          url: "/grammar-videos/7./7.66.mp4"
        },
        "7.67": %{
          page: "209",
          url: "/grammar-videos/7./7.67.mp4"
        },
        "7.68": %{
          page: "209",
          url: "/grammar-videos/7./7.68.mp4"
        },
        "7.69": %{
          page: "209",
          url: "/grammar-videos/7./7.69.mp4"
        },
        "7.70": %{
          page: "209",
          url: "/grammar-videos/7./7.70.mp4"
        },
        "7.71": %{
          page: "210",
          url: "/grammar-videos/7./7.71.mp4"
        },
        "7.72": %{
          page: "210",
          url: "/grammar-videos/7./7.72.mp4"
        },
        "7.73": %{
          page: "210",
          url: "/grammar-videos/7./7.73.mp4"
        },
        "7.74": %{
          page: "210",
          url: "/grammar-videos/7./7.74.mp4"
        },
        "7.77": %{
          page: "211",
          url: "/grammar-videos/7./7.77.mp4"
        },
        "7.78": %{
          page: "211",
          url: "/grammar-videos/7./7.78.mp4"
        },
        "7.79": %{
          page: "211",
          url: "/grammar-videos/7./7.79.mp4"
        },
        "7.80": %{
          page: "212",
          url: "/grammar-videos/7./7.80.mp4"
        },
        "7.81": %{
          page: "212",
          url: "/grammar-videos/7./7.81.mp4"
        },
        "7.82": %{
          page: "212",
          url: "/grammar-videos/7./7.82.mp4"
        },
        "7.83": %{
          page: "212",
          url: "/grammar-videos/7./7.83.mp4"
        },
        "7.84": %{
          page: "212",
          url: "/grammar-videos/7./7.84.mp4"
        },
        "7.85": %{
          page: "212",
          url: "/grammar-videos/7./7.85.mp4"
        },
        "7.86": %{
          page: "213",
          url: "/grammar-videos/7./7.86.mp4"
        },
        "7.87": %{
          page: "213",
          url: "/grammar-videos/7./7.87.mp4"
        },
        "7.88": %{
          page: "213",
          url: "/grammar-videos/7./7.88.mp4"
        },
        "7.89": %{
          page: "214",
          url: "/grammar-videos/7./7.89.mp4"
        },
        "7.90": %{
          page: "214",
          url: "/grammar-videos/7./7.90.mp4"
        },
        "7.91": %{
          page: "214",
          url: "/grammar-videos/7./7.91.mp4"
        },
        "7.92": %{
          page: "214",
          url: "/grammar-videos/7./7.92.mp4"
        }
      ],
      "Chapter 8": [
        "8.1": %{
          page: "223",
          url: "/grammar-videos/8./8.1.mp4"
        },
        "8.2": %{
          page: "224",
          url: "/grammar-videos/8./8.2.mp4"
        },
        "8.3": %{
          page: "225",
          url: "/grammar-videos/8./8.3.mp4"
        },
        "8.4": %{
          page: "226",
          url: "/grammar-videos/8./8.4.mp4"
        },
        "8.7": %{
          page: "242",
          url: "/grammar-videos/8./8.7.mp4"
        },
        "8.8": %{
          page: "243",
          url: "/grammar-videos/8./8.8.mp4"
        },
        "8.9": %{
          page: "243",
          url: "/grammar-videos/8./8.9.mp4"
        },
        "8.10": %{
          page: "243",
          url: "/grammar-videos/8./8.10.mp4"
        },
        "8.11": %{
          page: "244",
          url: "/grammar-videos/8./8.11.mp4"
        },
        "8.12": %{
          page: "244",
          url: "/grammar-videos/8./8.12.mp4"
        },
        "8.13": %{
          page: "244",
          url: "/grammar-videos/8./8.13.mp4"
        },
        "8.14": %{
          page: "244",
          url: "/grammar-videos/8./8.14.mp4"
        },
        "8.15": %{
          page: "246",
          url: "/grammar-videos/8./8.15.mp4"
        },
        "8.16": %{
          page: "246",
          url: "/grammar-videos/8./8.16.mp4"
        },
        "8.17": %{
          page: "246",
          url: "/grammar-videos/8./8.17.mp4"
        },
        "8.18": %{
          page: "246",
          url: "/grammar-videos/8./8.18.mp4"
        },
        "8.19": %{
          page: "246",
          url: "/grammar-videos/8./8.19.mp4"
        },
        "8.20": %{
          page: "246",
          url: "/grammar-videos/8./8.20.mp4"
        },
        "8.21": %{
          page: "247",
          url: "/grammar-videos/8./8.21.mp4"
        },
        "8.22": %{
          page: "249",
          url: "/grammar-videos/8./8.22.mp4"
        },
        "8.23": %{
          page: "249",
          url: "/grammar-videos/8./8.23.mp4"
        },
        "8.24": %{
          page: "249",
          url: "/grammar-videos/8./8.24.mp4"
        },
        "8.25": %{
          page: "250",
          url: "/grammar-videos/8./8.25.mp4"
        },
        "8.26": %{
          page: "250",
          url: "/grammar-videos/8./8.26.mp4"
        },
        "8.27": %{
          page: "251",
          url: "/grammar-videos/8./8.27.mp4"
        },
        "8.28": %{
          page: "251",
          url: "/grammar-videos/8./8.28.mp4"
        },
        "8.29": %{
          page: "251",
          url: "/grammar-videos/8./8.29.mp4"
        },
        "8.30": %{
          page: "251",
          url: "/grammar-videos/8./8.30.mp4"
        },
        "8.31": %{
          page: "251",
          url: "/grammar-videos/8./8.31.mp4"
        },
        "8.32": %{
          page: "251",
          url: "/grammar-videos/8./8.32.mp4"
        },
        "8.33": %{
          page: "252",
          url: "/grammar-videos/8./8.33.mp4"
        },
        "8.34": %{
          page: "252",
          url: "/grammar-videos/8./8.34.mp4"
        }
      ],
      "Chapter 9": [
        "9.20a": %{
          page: "264",
          url: "/grammar-videos/9./9.20a.mp4"
        },
        "9.20b": %{
          page: "266",
          url: "/grammar-videos/9./9.20b.mp4"
        },
        "9.21a": %{
          page: "266",
          url: "/grammar-videos/9./9.21a.mp4"
        },
        "9.21b": %{
          page: "266",
          url: "/grammar-videos/9./9.21b.mp4"
        },
        "9.21c": %{
          page: "266",
          url: "/grammar-videos/9./9.21c.mp4"
        },
        "9.21d": %{
          page: "266",
          url: "/grammar-videos/9./9.21d.mp4"
        },
        "9.21e": %{
          page: "266",
          url: "/grammar-videos/9./9.21e.mp4"
        },
        "9.21f": %{
          page: "266",
          url: "/grammar-videos/9./9.21f.mp4"
        },
        "9.21g": %{
          page: "266",
          url: "/grammar-videos/9./9.21g.mp4"
        },
        "9.21h": %{
          page: "266",
          url: "/grammar-videos/9./9.21h.mp4"
        },
        "9.22a": %{
          page: "267",
          url: "/grammar-videos/9./9.22a.mp4"
        },
        "9.22b": %{
          page: "267",
          url: "/grammar-videos/9./9.22b.mp4"
        },
        "9.25a": %{
          page: "268",
          url: "/grammar-videos/9./9.25a.mp4"
        },
        "9.25b": %{
          page: "268",
          url: "/grammar-videos/9./9.25b.mp4"
        },
        "9.26": %{
          page: "268",
          url: "/grammar-videos/9./9.26.mp4"
        },
        "9.27": %{
          page: "269",
          url: "/grammar-videos/9./9.27.mp4"
        },
        "9.30": %{
          page: "269",
          url: "/grammar-videos/9./9.30.mp4"
        },
        "9.31": %{
          page: "269",
          url: "/grammar-videos/9./9.31.mp4"
        },
        "9.32": %{
          page: "270",
          url: "/grammar-videos/9./9.32.mp4"
        },
        "9.33": %{
          page: "270",
          url: "/grammar-videos/9./9.33.mp4"
        },
        "9.34": %{
          page: "270",
          url: "/grammar-videos/9./9.34.mp4"
        },
        "9.35": %{
          page: "270",
          url: "/grammar-videos/9./9.35.mp4"
        },
        "9.38.v1": %{
          page: "274",
          url: "/grammar-videos/9./9.38.v1.mp4"
        },
        "9.38.v2": %{
          page: "274",
          url: "/grammar-videos/9./9.38.v2.mp4"
        },
        "9.39": %{
          page: "275",
          url: "/grammar-videos/9./9.39.mp4"
        },
        "9.41": %{
          page: "275",
          url: "/grammar-videos/9./9.41.mp4"
        },
        "9.42": %{
          page: "276",
          url: "/grammar-videos/9./9.42.mp4"
        }
      ]
    ]
  end

  # def mount(_params, _session, socket) do
  #   email = Phoenix.Flash.get(socket.assigns.flash, :email)
  #   form = to_form(%{"email" => email}, as: "user")
  #   {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  # end
end
