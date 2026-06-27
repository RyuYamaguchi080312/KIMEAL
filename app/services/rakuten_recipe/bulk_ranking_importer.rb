# frozen_string_literal: true

module RakutenRecipe
  class BulkRankingImporter
    DEFAULT_TARGET_COUNT = 100
    DEFAULT_SLEEP_SECONDS = 5

    def initialize(importer: RankingImporter.new, io: $stdout, sleeper: ->(seconds) { sleep seconds })
      @importer = importer
      @io = io
      @sleeper = sleeper
    end

    def import(target_count: DEFAULT_TARGET_COUNT, sleep_seconds: DEFAULT_SLEEP_SECONDS)
      target_count = normalize_count(target_count, DEFAULT_TARGET_COUNT)
      sleep_seconds = normalize_count(sleep_seconds, DEFAULT_SLEEP_SECONDS)
      target_total = Recipe.external_api.count + target_count

      io.puts "目標: 楽天API由来レシピを#{target_count}件追加"
      io.puts "現在: #{Recipe.external_api.count}件"

      target_categories.each do |category|
        break if Recipe.external_api.count >= target_total

        import_category(category)
        sleep_between_requests(sleep_seconds) if Recipe.external_api.count < target_total
      end

      io.puts "完了: #{Recipe.external_api.count}件"
    end

    private

    attr_reader :importer, :io, :sleeper

    def target_categories
      Category.where("external_id LIKE ?", "%-%-%")
              .where.not(id: Recipe.external_api.select(:category_id))
              .order(:id)
    end

    def import_category(category)
      before_count = Recipe.external_api.count
      importer.import(category)
      imported_count = Recipe.external_api.count - before_count

      io.puts "#{category.id}: #{category.name} #{imported_count}件 / 合計#{Recipe.external_api.count}件"
    rescue StandardError => e
      io.puts "#{category.id}: #{category.name} 失敗 #{e.class} #{e.message}"
    end

    def sleep_between_requests(seconds)
      return if seconds.zero?

      sleeper.call(seconds)
    end

    def normalize_count(value, default)
      count = value.to_i

      count.positive? ? count : default
    end
  end
end
