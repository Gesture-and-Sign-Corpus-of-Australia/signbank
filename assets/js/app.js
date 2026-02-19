// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import {InitSorting} from "./init_sorting"

let Uploaders = {}
let Hooks = {}

Hooks.InitSorting = InitSorting

Hooks.UnsavedChanges = {
  mounted() {
    this.beforeUnload = (e) => {
      if (this.el.dataset.touched === "true") {
        e.preventDefault();
        e.returnValue = "";
      }
    };
    window.addEventListener("beforeunload", this.beforeUnload);

    // Intercept LiveView patch navigation (tab switches, back nav)
    this.handleBeforeNav = (e) => {
      if (this.el.dataset.touched === "true") {
        if (!window.confirm("You have unsaved changes. Leave without saving?")) {
          e.preventDefault();
          e.stopImmediatePropagation();
        }
      }
    };
    window.addEventListener("phx:page-loading-start", this.handleBeforeNav);
  },

  destroyed() {
    window.removeEventListener("beforeunload", this.beforeUnload);
    window.removeEventListener("phx:page-loading-start", this.handleBeforeNav);
  }
}

Hooks.VideoAutoplay = {
  mounted() {
    this.el.addEventListener('mouseenter', () => {
      this.el.play()
    })
  }
}

Hooks.CrudePreferenceHandler = {
  mounted() {
    const isLoggedIn = this.el.dataset.loggedIn === 'true';

    if (isLoggedIn) {
      // Force crude signs on for authenticated users and mark as forced
      localStorage.setItem('allowCrudeSigns', 'true');
      localStorage.setItem('allowCrudeForced', 'true');
      this.pushEvent("crude_preference_received", { allow_crude_signs: true });
      // No listeners needed because the user cannot change this setting when logged in
      return;
    }

    // Anonymous users: Check if the forced flag is set (indicates logout)
    const wasForced = localStorage.getItem('allowCrudeForced') === 'true';
    if (wasForced) {
      // User just logged out, clear the forced flag and reset to hidden
      localStorage.setItem('allowCrudeForced', 'false');
      localStorage.setItem('allowCrudeSigns', 'false');
    }

    // Honor existing anonymous preference (default hidden)
    const allowCrudeSigns = localStorage.getItem('allowCrudeSigns') === 'true';
    this.pushEvent("crude_preference_received", { allow_crude_signs: allowCrudeSigns });
    
    // Listen for preference changes from settings page
    this.handleEvent("get_crude_preference", () => {
      const allowCrude = localStorage.getItem('allowCrudeSigns') === 'true';
      this.pushEvent("crude_preference_received", { allow_crude_signs: allowCrude });
    });
    
    // Listen for global preference changes
    const handleSettingsChange = (event) => {
      const allowCrude = event.detail.allowCrudeSigns;
      this.pushEvent("crude_preference_received", { allow_crude_signs: allowCrude });
    };
    
    window.addEventListener('crudeSettingsChanged', handleSettingsChange);
    
    // Store reference for cleanup
    this._handleSettingsChange = handleSettingsChange;
  },
  
  destroyed() {
    if (this._handleSettingsChange) {
      window.removeEventListener('crudeSettingsChanged', this._handleSettingsChange);
    }
  }
}

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach(entry => {
    let formData = new FormData()
    let { url, fields } = entry.meta
    Object.entries(fields).forEach(([key, val]) => formData.append(key, val))
    formData.append("file", entry.file)
    let xhr = new XMLHttpRequest()
    onViewError(() => xhr.abort())
    xhr.onload = () => xhr.status === 204 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()
    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100)
        if (percent < 100) { entry.progress(percent) }
      }
    })

    xhr.open("POST", url, true)
    xhr.send(formData)
  })
}


const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  uploaders: Uploaders,
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

window.addHandshapeFilter = (value) => {
  const searchForm = document.querySelector('.navbar form[action="/dictionary"]');
  const id = "search-handshape-filter";
  let el = document.getElementById(id);
  if (el) {
    if (value) {
      el.value = value
      el.name = "handshape"
    } else {
      el.remove()
    }
  } else {
    el = document.createElement("input", {
      id,
      value,
      type: "hidden",
      name: "handshape",
    })
    searchForm.appendChild(el)
  }
  // <input id="search-handshape-filter" type="hidden" name="handshape" value="" />

}

Hooks.VideoPlayer = {
  mounted() {
    const video = this.el;
    const videoId = video.id;

    this.handleEvent("seek_video", ({video_id, time}) => {
      const v = document.getElementById(video_id);
      if (v) {
        v.currentTime = time;
        v.play();
      }
    });

    // Broadcast timeupdate so ElanPlayhead hooks can follow along
    const onTimeUpdate = () => {
      window.dispatchEvent(new CustomEvent("video_timeupdate", {
        detail: { video_id: videoId, time: video.currentTime }
      }));
    };
    video.addEventListener("timeupdate", onTimeUpdate);

    // Spacebar to toggle play/pause (only when this video's viewer area is in focus)
    const onKeyDown = (e) => {
      if (e.code !== "Space" || e.repeat) return;
      // Don't intercept if user is typing in an input/textarea
      const tag = document.activeElement?.tagName;
      if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return;
      e.preventDefault();
      e.stopPropagation();
      // Blur the video so native controls don't also toggle on keyup
      if (document.activeElement === video || video.contains(document.activeElement)) {
        document.activeElement.blur();
      }
      if (video.paused) {
        video.play();
      } else {
        video.pause();
      }
    };
    // Prevent the browser from firing a native "click" on the focused video on key release,
    // which would undo our toggle.
    const onKeyUp = (e) => {
      if (e.code !== "Space") return;
      const tag = document.activeElement?.tagName;
      if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return;
      e.preventDefault();
      e.stopPropagation();
    };
    document.addEventListener("keydown", onKeyDown, true);
    document.addEventListener("keyup", onKeyUp, true);

    this._cleanup = () => {
      video.removeEventListener("timeupdate", onTimeUpdate);
      document.removeEventListener("keydown", onKeyDown);
      document.removeEventListener("keyup", onKeyUp);
    };
  },

  destroyed() {
    if (this._cleanup) this._cleanup();
  }
};

Hooks.ElanPlayhead = {
  mounted() {
    const el = this.el;
    const videoId = el.dataset.videoId;
    const duration = parseFloat(el.dataset.duration);        // ms
    const pxPerMs = parseFloat(el.dataset.pixelsPerMs);
    const playhead = el.querySelector("[id$='-playhead']");
    const ruler = el.querySelector("[id$='-ruler']");

    if (!playhead || !ruler) return;

    // Show the playhead
    playhead.style.display = "";

    // ---- Follow video playback ----
    const onTimeUpdate = (e) => {
      if (e.detail.video_id !== videoId) return;
      const timeMs = e.detail.time * 1000;
      const x = timeMs * pxPerMs;
      playhead.style.left = x + "px";

      // Auto-scroll to keep the playhead visible within the container
      const viewLeft = el.scrollLeft;
      const viewRight = viewLeft + el.clientWidth;
      // Use a margin so the playhead doesn't hug the very edge
      const margin = el.clientWidth * 0.2;
      if (x > viewRight - margin) {
        el.scrollLeft = x - margin;
      } else if (x < viewLeft) {
        el.scrollLeft = Math.max(0, x - margin);
      }
    };
    window.addEventListener("video_timeupdate", onTimeUpdate);

    // ---- Helper: compute time from mouse x position ----
    // getBoundingClientRect() is viewport-relative and already accounts for scroll,
    // so we must NOT add el.scrollLeft (that would double-count).
    const timeFromMouseEvent = (e) => {
      const rect = ruler.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const clampedX = Math.max(0, Math.min(x, duration * pxPerMs));
      return { x: clampedX, timeSec: (clampedX / pxPerMs) / 1000 };
    };

    // ---- Click on ruler to seek ----
    const onRulerClick = (e) => {
      const { x, timeSec } = timeFromMouseEvent(e);
      const video = document.getElementById(videoId);
      if (video) {
        video.currentTime = timeSec;
        video.play();
      }
      playhead.style.left = x + "px";
    };
    ruler.addEventListener("click", onRulerClick);

    // ---- Drag on ruler to scrub (mousedown on ruler starts drag) ----
    let dragging = false;

    const onRulerMouseDown = (e) => {
      // Only left-click
      if (e.button !== 0) return;
      e.preventDefault();
      dragging = true;
      document.body.style.cursor = "grabbing";
      document.body.style.userSelect = "none";

      // Immediately seek to click position
      const { x, timeSec } = timeFromMouseEvent(e);
      playhead.style.left = x + "px";
      const video = document.getElementById(videoId);
      if (video) video.currentTime = timeSec;
    };
    ruler.addEventListener("mousedown", onRulerMouseDown);

    // Also allow starting a drag from the playhead handle
    const handle = playhead.querySelector("div");
    const onHandleMouseDown = (e) => {
      e.preventDefault();
      dragging = true;
      document.body.style.cursor = "grabbing";
      document.body.style.userSelect = "none";
    };
    if (handle) handle.addEventListener("mousedown", onHandleMouseDown);

    const onMouseMove = (e) => {
      if (!dragging) return;
      const { x, timeSec } = timeFromMouseEvent(e);
      playhead.style.left = x + "px";
      const video = document.getElementById(videoId);
      if (video) video.currentTime = timeSec;
    };

    const onMouseUp = () => {
      if (!dragging) return;
      dragging = false;
      document.body.style.cursor = "";
      document.body.style.userSelect = "";
    };

    document.addEventListener("mousemove", onMouseMove);
    document.addEventListener("mouseup", onMouseUp);

    // Store references for cleanup
    this._cleanup = () => {
      window.removeEventListener("video_timeupdate", onTimeUpdate);
      ruler.removeEventListener("click", onRulerClick);
      ruler.removeEventListener("mousedown", onRulerMouseDown);
      if (handle) handle.removeEventListener("mousedown", onHandleMouseDown);
      document.removeEventListener("mousemove", onMouseMove);
      document.removeEventListener("mouseup", onMouseUp);
    };
  },

  destroyed() {
    if (this._cleanup) this._cleanup();
  }
};

window.validateSearchForm = (event) => {
  const searchInput = document.getElementById('main-search-input');
  if (!searchInput || !searchInput.value || searchInput.value.trim() === '') {
    event.preventDefault();
    return false;
  }
  return true;
}

// Helper function to check if crude signs should be shown
window.allowCrudeSigns = () => {
  return localStorage.getItem('allowCrudeSigns') === 'true';
}

// TODO: use this to highlight the current selected phonological search handshape/location
window.addEventListener("phx:phon-filter-highlight", (e) => {
  if (e.detail.hasOwnProperty('location')) {
    [...document.querySelectorAll(".location_filter_container > *")].forEach(x => x.classList.remove("highlight"));
    
    let els = document.querySelectorAll(`[phx-value-location="${e.detail.location}"]`);
    for (let el of [...els]) {
      el.classList.add("highlight");
    }
  }
  if (e.detail.hasOwnProperty('handshape')) {
    [...document.querySelector(`#handshapegrid`).children].forEach(x => x.classList.remove("highlight"));
    let el = document.querySelector(`[phx-value-handshape="${e.detail.handshape}"]`);
    if (el) {
      el.classList.add("highlight");
    }
  }
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Open a <dialog> modal from a server-pushed event
window.addEventListener("phx:open_modal", (e) => {
  const dialog = document.getElementById(e.detail.id);
  if (dialog && !dialog.open) dialog.showModal();
});

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

