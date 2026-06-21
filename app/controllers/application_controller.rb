class ApplicationController < ActionController::Base
  # 必要な機能を持つモダンブラウザのみ許可する
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_sign_up_path_for(_resource)
    home_path
  end

  def after_sign_in_path_for(_resource)
    home_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
