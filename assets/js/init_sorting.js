import Sortable from "../vendor/sortable"

export const InitSorting = {
  mounted() {
    new Sortable(this.el, {
      handle: "[data-drag-handle]",
      animation: 150,
      ghostClass: "bg-yellow-100",
      dragClass: "shadow-2xl",
      onEnd: (evt) => {
        this.el.closest("form").querySelector("input").dispatchEvent(new Event("input", {bubbles: true}))
      }
    })
  }
}
