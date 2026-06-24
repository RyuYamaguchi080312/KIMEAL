# frozen_string_literal: true

module RakutenRecipe
  class CategoryImporter
    def initialize(client: Client.new)
      @client = client
    end

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

      return existing_category if record.new_record? && existing_category&.external_id.present?

      record = existing_category || record if record.new_record?
      record.assign_attributes(name: name, external_id: external_id)
      record.save!
      record
    end
  end
end
