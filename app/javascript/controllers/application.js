import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Stimulusの開発体験を整える
application.debug = false
window.Stimulus   = application

export { application }
