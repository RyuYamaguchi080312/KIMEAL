import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    this.containerTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.trim())
  }

  remove(event) {
    event.preventDefault()

    const item = event.currentTarget.closest("[data-tag-fields-item]")
    if (this.containerTarget.querySelectorAll("[data-tag-fields-item]").length === 1) {
      item.querySelector("input").value = ""
      return
    }

    item.remove()
  }
}
