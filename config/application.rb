require_relative "boot"

require "rails/all"

# Gemfileに定義したgemを読み込む
Bundler.require(*Rails.groups)

module Kimeal
  class Application < Rails::Application
    # Rails 8.0の標準設定を使用する
    config.load_defaults 8.0
    config.i18n.default_locale = :ja

    # Rubyファイルを含まないlib配下のディレクトリは自動読み込み対象から外す
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
