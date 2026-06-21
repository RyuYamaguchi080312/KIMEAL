# テスト環境専用の設定です。
# テストDBは実行ごとに作り直されるため、永続データの保存先には使いません。

Rails.application.configure do
  # このファイルの設定は config/application.rb より優先される

  # テスト中はファイル監視を行わない
  config.enable_reloading = false

  # CIでは全コードを読み込み、eager loadingの問題も検出する
  config.eager_load = ENV["CI"].present?

  # テスト時の静的ファイル配信をキャッシュする
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # エラー詳細を表示する
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # rescue対象の例外はテンプレート表示し、それ以外は例外として扱う
  config.action_dispatch.show_exceptions = :rescuable

  # テスト環境ではCSRF保護を無効化する
  config.action_controller.allow_forgery_protection = false

  # テスト用の一時保存先を使う
  config.active_storage.service = :test

  # 実際にはメール送信せず、ActionMailer::Base.deliveries に蓄積する
  config.action_mailer.delivery_method = :test

  # メール内リンクで使うホスト
  config.action_mailer.default_url_options = { host: "example.com" }

  # 非推奨警告を標準エラーに出力する
  config.active_support.deprecation = :stderr

  # 翻訳漏れをエラーにしたい場合に有効化する
  # config.i18n.raise_on_missing_translations = true

  # レンダリングされたビューにファイル名コメントを付けたい場合に有効化する
  # config.action_view.annotate_rendered_view_with_filenames = true

  # before_actionのonly/exceptで存在しないactionを指定した場合にエラーにする
  config.action_controller.raise_on_missing_callback_actions = true
end
