# frozen_string_literal: true

Devise.setup do |config|
  require "devise/orm/active_record"

  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other
end
