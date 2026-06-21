class ApplicationController < ActionController::Base
  # 必要な機能を持つモダンブラウザのみ許可する
  allow_browser versions: :modern
end
