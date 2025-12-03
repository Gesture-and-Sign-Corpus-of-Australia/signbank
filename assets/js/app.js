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
// Temporarily comment out the import to test the basic setup
// import { AuslanSpellContainerController } from "auslan-spell/lib";
// Import Auslan Spell styles
// import "auslan-spell/dist/auslan-spell-styles.css";

// console.log("AuslanSpellContainerController imported:", AuslanSpellContainerController);

// Placeholder for testing
console.log("Auslan Spell integration - checking for container element");

const models = [
  {
    id: "right-handed-model",
    displayName: "Right Handed Auslan",
    filepath: "/models/session2_realisticHands.glb",
    charToAnimationName: (char) => `Armature|${char}_righthand`,
    config: {
      cameraFOV: 45,
      frontLightingPosition: {
        x: 0 + 0.25,
        y: 1.75 + 0.25,
        z: 0.3 + 2,
      },
      backLightingPosition: {
        x: 0 + 0.25,
        y: 1.75 + 0.25,
        z: 0.3 - 0.5,
      },
      underLightingPosition: {
        x: 0 + 0.25,
        y: 1.75 - 2.2,
        z: 0.3 + 2,
      },
      modelPositionFunc: (width, _) => {
        const y = width > 720 ? 1.75 : 1.6;
        return {
          x: 0.0,
          y: y,
          z: 0.3,
        };
      },
      cameraPositionFunc: (width, _) => {
        const z = width > 720 ? 1.5 : 1.55; // Fixed: was using undefined 'z'
        return {
          x: 0.05,
          y: 1.75,
          z: z,
        };
      },
      frontCameraPositionFunc: (width, _) => {
        const z = width > 720 ? 1.5 : 1.55;
        return {
          x: 0.05,
          y: 1.75,
          z: z,
        };
      },
      backCameraPositionFunc: (width, _) => {
        const z = width > 720 ? -0.25 : 0;
        return {
          x: 0,
          y: 1.95,
          z: z,
        };
      },
    },
  },
];

const theme = {
  background: "#e6e6e6",
  primary: "#fa5c5c",
  secondary: "#C83333",
  border: "#cccccc",
  text: "#383838",
  buttonText: "#fffafa",
  subText: "#9c9c9c",
  fontFamily:
    "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif",
};

// Initialize the Auslan Spell container when DOM is loaded
let auslanContainer = null;

document.addEventListener("DOMContentLoaded", () => {
  console.log("DOM loaded, looking for auslan-spell-container...");
  const containerElement = document.getElementById("auslan-spell-container");
  
  if (containerElement) {
    console.log("Found auslan-spell-container element:", containerElement);
    console.log("Container element innerHTML:", containerElement.innerHTML);
    console.log("Container element styles:", getComputedStyle(containerElement));
    
    // For now, just add some placeholder content to test
    containerElement.innerHTML = '<div style="background: lightblue; padding: 20px; text-align: center;">Auslan Spell Container Found! Ready for integration.</div>';
    
    // TODO: Replace this with actual AuslanSpellContainerController when import issue is resolved
    /*
    try {
      console.log("Attempting to create AuslanSpellContainerController...");
      auslanContainer = new AuslanSpellContainerController(models, "auslan-spell-container", theme);
      console.log("Successfully created auslanContainer:", auslanContainer);
      
      // Add keyboard shortcuts for frame navigation
      document.addEventListener("keydown", (e) => {
        if (auslanContainer && auslanContainer.handsController) {
          if (e.key === "[") {
            auslanContainer.handsController.decrementElapsedTime(1);
          } else if (e.key === "]") {
            auslanContainer.handsController.incrementElapsedTime(1);
          } else if (e.key === "-") {
            auslanContainer.handsController.decrementElapsedTime(30);
          } else if (e.key === "=") {
            auslanContainer.handsController.incrementElapsedTime(30);
          }
        }
      });
    } catch (error) {
      console.error("Failed to initialize Auslan Spell container:", error);
      console.error("Error stack:", error.stack);
    }
    */
  } else {
    console.error("Could not find element with id 'auslan-spell-container'");
    console.log("Available elements with 'auslan' in id:");
    document.querySelectorAll("[id*='auslan']").forEach(el => {
      console.log("- Found element:", el.id, el);
    });
  }
});

// Clean up on page unload
window.addEventListener("beforeunload", () => {
  if (auslanContainer && auslanContainer.cleanUpContainer) {
    auslanContainer.cleanUpContainer();
  }
});



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

