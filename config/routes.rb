Rails.application.routes.draw do
  devise_for :users

  # アプリが正常に起動しているか確認するヘルスチェック用ルート
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA対応を進める場合に有効化する
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # トップページ
  root "top#index"
end
