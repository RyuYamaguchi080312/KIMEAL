# frozen_string_literal: true

module RakutenRecipe
  # 楽天レシピAPIのカテゴリ一覧を取得し、categoriesテーブルへ保存するサービス。
  # 楽天APIの中分類・小分類は親IDだけを持つため、KIMEALで使うexternal_idを階層形式に組み立てる。
  class CategoryImporter
    # @param client [#category_list] 楽天カテゴリ一覧を取得できるクライアント
    def initialize(client: Client.new)
      @client = client
    end

    # 大分類・中分類・小分類を保存または更新する。
    #
    # @return [Array<Category>] 保存または更新したカテゴリ
    # @raise [KeyError] 楽天APIレスポンスに必須キーがない場合
    # @raise [ActiveRecord::RecordInvalid] カテゴリ保存に失敗した場合
    def import
      result = client.category_list.fetch("result")
      imported_categories = []
      large_external_ids = {}
      medium_external_ids = {}

      each_category(result["large"]) do |category|
        external_id = category.fetch("categoryId").to_s
        large_external_ids[category.fetch("categoryId").to_s] = external_id
        imported_categories << save_category(category, external_id)
      end

      each_category(result["medium"]) do |category|
        parent_id = category["parentCategoryId"].to_s
        external_id = [large_external_ids[parent_id], category.fetch("categoryId")].compact.join("-")
        medium_external_ids[category.fetch("categoryId").to_s] = external_id
        imported_categories << save_category(category, external_id)
      end

      each_category(result["small"]) do |category|
        parent_id = category["parentCategoryId"].to_s
        # 小分類は「大分類ID-中分類ID-小分類ID」の形式にして、ランキングAPIのcategoryIdへそのまま渡せるようにする。
        external_id = [medium_external_ids[parent_id], category.fetch("categoryId")].compact.join("-")
        imported_categories << save_category(category, external_id)
      end

      imported_categories
    end

    private

    attr_reader :client

    def each_category(categories, &block)
      Array(categories).each(&block)
    end

    def save_category(category, external_id)
      name = category.fetch("categoryName")
      record = Category.find_or_initialize_by(external_id: external_id)
      existing_category = Category.find_by(name: name)

      # 既存の手入力カテゴリにexternal_idがある場合は、楽天カテゴリの重複保存を避ける。
      return existing_category if record.new_record? && existing_category&.external_id.present?

      record = existing_category || record if record.new_record?
      record.assign_attributes(name: name, external_id: external_id)
      record.save!
      record
    end
  end
end
