class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # 必要な機能を持つモダンブラウザのみ許可する
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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

  private

  def user_not_authorized
    redirect_to root_path, alert: "管理者権限が必要です。"
  end
end
