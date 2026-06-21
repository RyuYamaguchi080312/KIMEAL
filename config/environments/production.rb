require "active_support/core_ext/integer/time"

Rails.application.configure do
  # このファイルの設定は config/application.rb より優先される

  # リクエストごとのコード再読み込みは行わない
  config.enable_reloading = false

  # 起動時に全コードを読み込む
  config.eager_load = true

  # エラー詳細は表示しない
  config.consider_all_requests_local = false

  # ビューのフラグメントキャッシュを有効化する
  config.action_controller.perform_caching = true

  # fingerprint付きアセットを長期キャッシュする
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # アセットサーバーを使う場合に設定する
  # config.asset_host = "http://assets.example.com"

  # アップロードファイルはローカルに保存する
  config.active_storage.service = :local

  # SSL終端済みのリバースプロキシ配下で動く想定にする
  config.assume_ssl = true

  # SSL通信を強制する
  config.force_ssl = true

  # ヘルスチェックだけHTTPSリダイレクトから除外したい場合に有効化する
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # request_id付きで標準出力にログを出す
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # 詳細ログが必要な場合は RAILS_LOG_LEVEL=debug を指定する
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # ヘルスチェックのログ出力を抑制する
  config.silence_healthcheck_path = "/up"

  # 非推奨警告は出力しない
  config.active_support.report_deprecations = false

  # Render initial deploy uses a single PostgreSQL database. Solid Cache can be
  # enabled later after its tables are configured.
  config.cache_store = :memory_store

  # Keep jobs in-process for the initial Render deployment. Move to a Render
  # background worker with Solid Queue when asynchronous jobs are introduced.
  config.active_job.queue_adapter = :async

  # メール送信エラーを検知したい場合に設定する
  # config.action_mailer.raise_delivery_errors = false

  # メール内リンクで使うホスト
  config.action_mailer.default_url_options = { host: "example.com" }

  # SMTP送信を使う場合に設定する
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # 翻訳が見つからない場合にデフォルトロケールへフォールバックする
  config.i18n.fallbacks = true

  # 本番環境ではマイグレーション後にschemaをdumpしない
  config.active_record.dump_schema_after_migration = false

  # 本番環境のinspectではidだけ表示する
  config.active_record.attributes_for_inspect = [ :id ]

  # Hostヘッダー攻撃対策として許可ホストを指定したい場合に設定する
  # config.hosts = [
  #   "example.com",
  #   /.*\.example\.com/
  # ]
  #
  # ヘルスチェックだけHost認可から除外したい場合に設定する
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
