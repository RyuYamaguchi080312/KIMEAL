import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "likedForm", "rejectedForm"]

  connect() {
    this.edgeGuard = 24
    this.threshold = 80
    this.resetState()
  }

  start(event) {
    if (this.isInteractiveElement(event.target)) {
      this.ignored = true
      return
    }

    if (event.clientX < this.edgeGuard || window.innerWidth - event.clientX < this.edgeGuard) {
      this.ignored = true
      return
    }

    this.dragging = true
    this.startX = event.clientX
    this.startY = event.clientY
    this.currentX = 0
    this.cardTarget.setPointerCapture(event.pointerId)
    this.cardTarget.classList.remove("transition-transform")
  }

  move(event) {
    if (!this.dragging || this.ignored) return

    const deltaX = event.clientX - this.startX
    const deltaY = event.clientY - this.startY

    if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 8) {
      event.preventDefault()
    }

    this.currentX = deltaX
    this.requestRender()
  }

  end() {
    if (!this.dragging || this.ignored) {
      this.resetState()
      return
    }

    const cardThreshold = Math.max(this.threshold, this.cardTarget.offsetWidth * 0.25)

    if (this.currentX >= cardThreshold) {
      this.submit(this.likedFormTarget)
    } else if (this.currentX <= -cardThreshold) {
      this.submit(this.rejectedFormTarget)
    } else {
      this.reset()
    }
  }

  reset() {
    if (this.hasCardTarget) {
      this.cancelRender()
      this.cardTarget.classList.add("transition-transform")
      this.cardTarget.style.transform = ""
    }
    this.resetState()
  }

  submit(form) {
    this.cancelRender()
    this.cardTarget.classList.add("transition-transform")
    this.cardTarget.style.transform = `translateX(${this.currentX > 0 ? 120 : -120}%) rotate(${this.currentX > 0 ? 12 : -12}deg)`
    form.requestSubmit()
  }

  requestRender() {
    if (this.frameRequested) return

    this.frameRequested = true
    this.frameId = requestAnimationFrame(() => {
      const rotate = Math.max(Math.min(this.currentX / 18, 8), -8)
      this.cardTarget.style.transform = `translateX(${this.currentX}px) rotate(${rotate}deg)`
      this.frameRequested = false
      this.frameId = null
    })
  }

  cancelRender() {
    if (this.frameId) {
      cancelAnimationFrame(this.frameId)
    }
    this.frameRequested = false
    this.frameId = null
  }

  resetState() {
    this.dragging = false
    this.ignored = false
    this.frameRequested = false
    this.frameId = null
    this.startX = 0
    this.startY = 0
    this.currentX = 0
  }

  isInteractiveElement(element) {
    return element.closest("a, button, input, select, textarea, label, form")
  }
}
