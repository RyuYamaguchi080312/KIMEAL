source "https://rubygems.org"

# Rails本体
gem "rails", "8.0.2"
# Rails 8標準のアセットパイプライン
gem "propshaft"
# データベースはPostgreSQLを使用
gem "pg", "~> 1.1"
# Webサーバー
gem "puma", ">= 5.0"
# JavaScriptをimportmapで管理
gem "importmap-rails"
# Hotwireによる画面遷移の高速化
gem "turbo-rails"
# Hotwire向けの軽量JavaScriptフレームワーク
gem "stimulus-rails"
# JSONレスポンス生成
gem "jbuilder"

gem "devise"
gem "pundit"
gem "faraday"
gem "ransack"

# has_secure_passwordを使う場合に有効化する
# gem "bcrypt", "~> 3.1.7"

# Windows環境でタイムゾーン情報を扱うために必要
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Rails.cache、Active Job、Action CableをDBバックエンドで扱う
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# 起動時間を短縮する
gem "bootsnap", require: false

# Kamalデプロイ用
gem "kamal", require: false

# 本番環境でのHTTPキャッシュや圧縮を補助する
gem "thruster", require: false

# Active Storageで画像変換を使う場合に有効化する
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "minitest", "~> 5.25"

  # デバッグ用
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # セキュリティ静的解析
  gem "brakeman", require: false

  # Rails向けのコードスタイルチェック
  gem "rubocop-rails-omakase", require: false

  gem "factory_bot_rails"
  gem "faker"
  gem "pry-byebug"
  gem "rspec-rails"
end

group :development do
  # 例外画面でコンソールを使う
  gem "web-console"
end

group :test do
  # システムテスト用
  gem "capybara"
  gem "selenium-webdriver"
end

gem "tailwindcss-rails", "~> 4.6"
