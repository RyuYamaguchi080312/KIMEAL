ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # 指定したワーカー数でテストを並列実行する
    parallelize(workers: :number_of_processors)

    # test/fixtures配下のfixtureを読み込む
    fixtures :all

    # 全テストで使うヘルパーメソッドはここに追加する
  end
end
