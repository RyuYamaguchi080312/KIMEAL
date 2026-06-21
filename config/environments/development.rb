require "active_support/core_ext/integer/time"

Rails.application.configure do
  # このファイルの設定は config/application.rb より優先される

  # サーバー再起動なしでコード変更を反映する
  config.enable_reloading = true

  # 起動時に全コードを読み込まない
  config.eager_load = false

  # エラー詳細を画面に表示する
  config.consider_all_requests_local = true

  # Server-Timingヘッダーを有効にする
  config.server_timing = true

  # rails dev:cache でコントローラキャッシュを切り替える
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # キャッシュを使わない場合は :null_store に変更する
  config.cache_store = :memory_store

  # アップロードファイルはローカルに保存する
  config.active_storage.service = :local

  # メール送信失敗で例外を出さない
  config.action_mailer.raise_delivery_errors = false

  # メールテンプレートの変更を即時反映する
  config.action_mailer.perform_caching = false

  # メール内リンクのホストをlocalhostにする
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # 非推奨警告をRailsログに出力する
  config.active_support.deprecation = :log

  # 未実行マイグレーションがある場合は画面表示時にエラーにする
  config.active_record.migration_error = :page_load

  # SQLを発行したコード箇所をログに表示する
  config.active_record.verbose_query_logs = true

  # SQLログに実行時情報のタグを付ける
  config.active_record.query_log_tags_enabled = true

  # ジョブを登録したコード箇所をログに表示する
  config.active_job.verbose_enqueue_logs = true

  # 翻訳漏れをエラーにしたい場合に有効化する
  # config.i18n.raise_on_missing_translations = true

  # レンダリングされたビューにファイル名コメントを付ける
  config.action_view.annotate_rendered_view_with_filenames = true

  # Action Cableを任意のoriginから許可したい場合に有効化する
  # config.action_cable.disable_request_forgery_protection = true

  # before_actionのonly/exceptで存在しないactionを指定した場合にエラーにする
  config.action_controller.raise_on_missing_callback_actions = true

  # rails generateで作成したファイルにRuboCop自動修正をかけたい場合に有効化する
  # config.generators.apply_rubocop_autocorrect_after_generate!
end
