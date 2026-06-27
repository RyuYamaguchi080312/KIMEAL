import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["deck", "card", "finished"]
  static values = {
    batchUrl: String,
    saveUrl: String
  }

  connect() {
    this.edgeGuard = 24
    this.prefetchThreshold = 3
    this.threshold = 80
    this.seenRecipeIds = this.cardTargets.map((card) => card.dataset.recipeId)
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
      this.submit("liked")
    } else if (this.currentX <= -cardThreshold) {
      this.submit("rejected")
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

  submit(direction) {
    const card = this.cardTarget
    const recipeId = card.dataset.recipeId

    this.cancelRender()
    card.classList.add("transition-transform")
    card.style.transform = `translateX(${this.currentX > 0 ? 120 : -120}%) rotate(${this.currentX > 0 ? 12 : -12}deg)`

    this.saveSwipe(recipeId, direction)
    this.advance(card)
  }

  advance(card) {
    card.remove()
    this.resetState()

    const nextCard = this.cardTargets[0]

    if (nextCard) {
      nextCard.classList.remove("hidden")
      this.fetchMoreIfNeeded()
    } else {
      this.fetchMoreIfNeeded(true)
    }
  }

  fetchMoreIfNeeded(force = false) {
    if (this.loadingBatch) return
    if (!force && this.cardTargets.length > this.prefetchThreshold) return

    this.loadingBatch = true
    fetch(this.batchUrlWithSeenIds(), {
      headers: { Accept: "application/json" }
    })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to fetch recipe batch")
        return response.json()
      })
      .then((data) => {
        data.recipes.forEach((recipe) => {
          this.deckTarget.insertAdjacentHTML("beforeend", recipe.html)
          this.seenRecipeIds.push(String(recipe.id))
        })

        const nextCard = this.cardTargets[0]
        if (nextCard) {
          nextCard.classList.remove("hidden")
        } else if (data.finished) {
          this.showFinished()
        }
      })
      .catch(() => {
        if (force && this.cardTargets.length === 0) this.showFinished()
      })
      .finally(() => {
        this.loadingBatch = false
      })
  }

  batchUrlWithSeenIds() {
    const url = new URL(this.batchUrlValue, window.location.origin)

    this.seenRecipeIds.forEach((id) => {
      url.searchParams.append("seen_recipe_ids[]", id)
    })

    return url.toString()
  }

  saveSwipe(recipeId, direction) {
    const body = new URLSearchParams()
    body.append("recipe_id", recipeId)
    body.append("direction", direction)

    fetch(this.saveUrlValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": this.csrfToken()
      },
      body
    })
  }

  showFinished() {
    if (this.hasFinishedTarget) {
      this.finishedTarget.classList.remove("hidden")
    }
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content
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
