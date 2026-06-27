# frozen_string_literal: true

module RakutenRecipe
  # 楽天レシピAPIのレスポンス1件分を、Recipeモデルへ保存できる属性Hashに変換する。
  # APIレスポンスのキー名とDBカラム名の違いをこのクラスに閉じ込める。
  class RecipeAttributes
    # @param recipe_data [Hash] 楽天レシピAPIのレシピデータ
    def initialize(recipe_data)
      @recipe_data = recipe_data
    end

    # @return [Hash] Recipeへassign_attributesできる属性
    # @raise [KeyError] 必須キーがレスポンスにない場合
    def to_h
      {
        source_type: :external_api,
        external_id: external_id,
        title: title,
        description: recipe_data["recipeDescription"],
        image_url: image_url,
        ingredients: ingredients,
        cooking_time: cooking_time,
        source_url: recipe_data["recipeUrl"]
      }
    end

    private

    attr_reader :recipe_data

    def external_id
      recipe_data.fetch("recipeId").to_s
    end

    def title
      recipe_data.fetch("recipeTitle")
    end

    def image_url
      recipe_data["foodImageUrl"].presence ||
        recipe_data["mediumImageUrl"].presence ||
        recipe_data["smallImageUrl"]
    end

    def ingredients
      # recipeMaterialは配列で返るため、画面で改行表示しやすい文字列に変換する。
      Array(recipe_data["recipeMaterial"]).join("\n")
    end

    def cooking_time
      # 「約10分」のような文字列から数値だけを取り出し、保存しやすい分単位にする。
      recipe_data["recipeIndication"].to_s[/\d+/]&.to_i
    end
  end
end
