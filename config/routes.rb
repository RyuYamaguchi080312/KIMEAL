Rails.application.routes.draw do
  devise_for :users

  # アプリが正常に起動しているか確認するヘルスチェック用ルート
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA対応を進める場合に有効化する
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "top#index"
  get "home", to: "home#index"
  resources :recipes, only: [:index]

  namespace :admin do
    resources :recipes, only: [:index, :new, :create, :edit, :update]
    resources :categories, only: [:index, :create, :update, :destroy]
    resources :tags, only: [:index, :create, :update, :destroy]
  end
end
