defmodule SignbankWeb.ElanViewer do
  @moduledoc """
  Component for displaying ELAN annotation files with timeline visualization.
  Includes a draggable red playhead synced to the video.
  """
  use SignbankWeb, :live_component

  # Generate tick marks every 500ms
  defp timeline_ticks(duration, pixels_per_ms) do
    interval = 500
    count = div(duration, interval)

    for i <- 0..count do
      ms = i * interval
      %{
        ms: ms,
        left: ms * pixels_per_ms,
        label: if(rem(i, 2) == 0, do: format_time(ms), else: nil),
        major: rem(i, 2) == 0
      }
    end
  end

  def render(assigns) do
    timeline_width = assigns.duration * assigns.pixels_per_ms
    ticks = timeline_ticks(assigns.duration, assigns.pixels_per_ms)
    tier_count = length(assigns.tiers)

    assigns =
      assigns
      |> assign(:timeline_width, timeline_width)
      |> assign(:ticks, ticks)
      |> assign(:tier_count, tier_count)

    ~H"""
    <div
      class="elan-viewer w-full overflow-x-auto relative"
      id={@id}
      phx-hook="ElanPlayhead"
      data-video-id={@video_id}
      data-duration={@duration}
      data-pixels-per-ms={@pixels_per_ms}
    >
      <div class="flex flex-row box-border">
        <%!-- Tier labels column: sticky so it stays visible on horizontal scroll --%>
        <div class="flex flex-col flex-shrink-0 sticky left-0 z-20 bg-white">
          <%!-- Empty corner cell above tier labels --%>
          <div class="h-8 border-b border-gray-400 border-r bg-gray-100"></div>
          <div
            :for={tier <- @tiers}
            class="h-10 border-b border-gray-300 border-r bg-slate-100 px-2 py-1 text-right whitespace-nowrap text-sm flex items-center justify-end"
          >
            {tier.name}
          </div>
        </div>

        <%!-- Timeline + annotations column --%>
        <div class="flex flex-col flex-grow min-w-0 relative">
          <%!-- Timeline ruler row with tick marks (also acts as the click-to-seek / scrub area) --%>
          <div
            id={"#{@id}-ruler"}
            class="h-8 border-b border-gray-400 bg-gray-50 relative cursor-crosshair"
            style={"width: #{@timeline_width}px; min-width: 100%;"}
          >
            <div
              :for={tick <- @ticks}
              class="absolute top-0 h-full"
              style={"left: #{tick.left}px;"}
            >
              <div class={[
                "absolute bottom-0 w-px bg-gray-400",
                if(tick.major, do: "h-4", else: "h-2")
              ]}></div>
              <span
                :if={tick.label}
                class="absolute top-0 text-[10px] text-gray-500 -translate-x-1/2 select-none"
              >
                {tick.label}
              </span>
            </div>
          </div>

          <%!-- Annotation rows --%>
          <div
            :for={tier <- @tiers}
            class="h-10 bg-gray-100 relative border-b border-gray-200"
            style={"width: #{@timeline_width}px; min-width: 100%;"}
          >
            <div
              :for={anno <- tier.annotations}
              class={[
                "hover:!min-w-fit hover:z-30 h-9 text-sm p-1 hover:drop-shadow rounded border whitespace-nowrap absolute overflow-hidden cursor-pointer top-px",
                if(highlight?(anno.text, @highlight),
                  do: "bg-amber-200 border-amber-500 hover:bg-amber-100 font-semibold",
                  else: "bg-gray-200 border-gray-600 hover:bg-blue-50"
                )
              ]}
              style={"width: #{(anno.end - anno.start) * @pixels_per_ms}px; left: #{anno.start * @pixels_per_ms}px;"}
              phx-click="seek_video"
              phx-value-time={anno.start}
              phx-target={@myself}
              title={anno.text}
            >
              {anno.text}
            </div>
          </div>

          <%!-- Playhead: red vertical line spanning the full height of the timeline --%>
          <div
            id={"#{@id}-playhead"}
            class="absolute top-0 bottom-0 w-0.5 bg-red-600 z-10 pointer-events-none"
            style="left: 0px; display: none;"
          >
            <%!-- Playhead handle (draggable) --%>
            <div class="absolute -top-1 -left-[5px] w-3 h-3 bg-red-600 rounded-full pointer-events-auto cursor-grab active:cursor-grabbing"></div>
          </div>


        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    pixels_per_ms = assigns[:pixels_per_ms] || 0.15

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:highlight, fn -> nil end)
     |> assign(:pixels_per_ms, pixels_per_ms)}
  end

  # Check if an annotation text matches the highlighted keyword (case-insensitive)
  defp highlight?(_, nil), do: false
  defp highlight?(text, keyword), do: String.downcase(text) == String.downcase(keyword)

  def handle_event("seek_video", %{"time" => time}, socket) do
    time_ms = String.to_integer(time)

    {:noreply,
     push_event(socket, "seek_video", %{
       video_id: socket.assigns.video_id,
       time: time_ms / 1000
     })}
  end

  defp format_time(ms) when is_integer(ms) do
    total_seconds = div(ms, 1000)
    minutes = div(total_seconds, 60)
    seconds = rem(total_seconds, 60)
    "#{minutes}:#{String.pad_leading(Integer.to_string(seconds), 2, "0")}"
  end

  defp format_time(_), do: "0:00"
end
