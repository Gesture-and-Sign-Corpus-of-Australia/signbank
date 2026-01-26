defmodule SignbankWeb.ElanViewer do
  @moduledoc """
  Component for displaying ELAN annotation files with timeline visualization.
  """
  use SignbankWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="elan-viewer w-full overflow-x-auto">
      <div class="flex flex-row box-border">
        <!-- Tier names column -->
        <div class="flex flex-col flex-shrink-0">
          <div class="h-10 border-b border-black border-r text-xl bg-gray-100">
            <!-- Empty top-left cell -->
          </div>
          <div
            :for={tier <- @tiers}
            class="h-10 border-b border-black border-r text-xl bg-slate-100 p-2 text-right whitespace-nowrap"
          >
            {tier.name}
          </div>
        </div>

        <!-- Timeline and annotations column -->
        <div class="flex flex-col flex-grow min-w-0">
          <div class="h-10 border-b border-black text-xl bg-slate-100 px-2">
            <!-- Timeline header - could add time markers here -->
            <div class="flex justify-between items-center h-full text-sm text-gray-600">
              <span>0:00</span>
              <span>{format_time(@duration)}</span>
            </div>
          </div>
          <div
            :for={tier <- @tiers}
            class="h-10 bg-gray-100 relative"
            style={"width: #{@duration * @pixels_per_ms}px; min-width: 100%;"}
          >
            <div
              :for={anno <- tier.annotations}
              class="hover:!min-w-fit hover:z-10 h-10 text-sm p-1 hover:drop-shadow hover:bg-gray-100 rounded-lg bg-gray-200 border border-gray-800 whitespace-nowrap absolute overflow-hidden cursor-pointer"
              style={"width: #{(anno.end - anno.start) * @pixels_per_ms}px; left: #{anno.start * @pixels_per_ms}px;"}
              phx-click="seek_video"
              phx-value-time={anno.start}
              phx-target={@myself}
              title={anno.text}
            >
              {anno.text}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    # Default to 6400/60000 ratio from original Vue code
    # This gives approximately 0.107 pixels per millisecond
    pixels_per_ms = assigns[:pixels_per_ms] || 6400 / 60000

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:pixels_per_ms, pixels_per_ms)}
  end

  def handle_event("seek_video", %{"time" => time}, socket) do
    # Push a browser event so the VideoPlayer hook can seek and autoplay
    time_ms = String.to_integer(time)

    {:noreply,
     push_event(socket, "seek_video", %{
       video_id: socket.assigns.video_id,
       time: time_ms / 1000
     })}
  end

  # Format milliseconds to mm:ss
  defp format_time(ms) when is_integer(ms) do
    total_seconds = div(ms, 1000)
    minutes = div(total_seconds, 60)
    seconds = rem(total_seconds, 60)
    "#{minutes}:#{String.pad_leading(Integer.to_string(seconds), 2, "0")}"
  end

  defp format_time(_), do: "0:00"
end
