import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "select", "count"]

  connect() {
    this.options = Array.from(this.selectTarget.options).map((option) => ({
      text: option.text,
      value: option.value
    }))

    this.filter()
  }

  filter() {
    const keyword = this.queryTarget.value.trim().toLowerCase()
    const selectedValue = this.selectTarget.value
    const filteredOptions = this.options.filter((option) => {
      return option.value === "" || option.text.toLowerCase().includes(keyword)
    })

    this.selectTarget.replaceChildren(
      ...filteredOptions.map((option) => {
        const element = new Option(option.text, option.value)
        element.selected = option.value === selectedValue
        return element
      })
    )

    if (this.hasCountTarget) {
      this.countTarget.textContent = `${Math.max(filteredOptions.length - 1, 0)}件`
    }
  }
}
