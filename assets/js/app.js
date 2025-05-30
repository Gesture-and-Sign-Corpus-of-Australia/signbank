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

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import {InitSorting} from "./init_sorting"

let Uploaders = {}
let Hooks = {}

Hooks.InitSorting = InitSorting

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

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  uploaders: Uploaders,
  hooks: Hooks,
  livePollFallbackMs: 2500,
  params: { _csrf_token: csrfToken }
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
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
