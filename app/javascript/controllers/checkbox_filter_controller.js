import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "item", "count"]

  connect() {
    this.filter()
  }

  filter() {
    const keyword = this.queryTarget.value.trim().toLowerCase()
    let visibleCount = 0

    this.itemTargets.forEach((item) => {
      const matched = item.dataset.filterText.toLowerCase().includes(keyword)
      item.classList.toggle("hidden", !matched)
      if (matched) visibleCount += 1
    })

    if (this.hasCountTarget) {
      this.countTarget.textContent = `${visibleCount}件`
    }
  }
}
