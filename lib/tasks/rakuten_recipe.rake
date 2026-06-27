# frozen_string_literal: true

namespace :rakuten_recipe do
  desc "楽天レシピAPIからカテゴリを取得してcategoriesへ保存する"
  task import_categories: :environment do
    count = RakutenRecipe::CategoryImporter.new.import.count
    puts "#{count}件のカテゴリを保存しました"
  end

  desc "楽天レシピAPIから指定カテゴリのランキングレシピを取得してrecipesへ保存する"
  task :import_ranking, [:category_id] => :environment do |_task, args|
    category = Category.find(args.fetch(:category_id))
    count = RakutenRecipe::RankingImporter.new.import(category).count
    puts "#{category.name} のレシピを#{count}件保存しました"
  end

  desc "楽天レシピAPIから小分類カテゴリのランキングレシピを目標件数まで保存する"
  task :import_rankings_until, [:target_count, :sleep_seconds] => :environment do |_task, args|
    RakutenRecipe::BulkRankingImporter.new.import(
      target_count: args[:target_count],
      sleep_seconds: args[:sleep_seconds]
    )
  end
end
