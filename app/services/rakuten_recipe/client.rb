# frozen_string_literal: true

module RakutenRecipe
  class Client
    class MissingCredentialsError < StandardError; end
    class RequestError < StandardError; end

    BASE_URL = "https://openapi.rakuten.co.jp/recipems/api/Recipe"

    def initialize(application_id: ENV["RAKUTEN_APPLICATION_ID"], access_key: ENV["RAKUTEN_ACCESS_KEY"])
      @application_id = application_id
      @access_key = access_key
    end

    def category_list(category_type: nil)
      params = {}
      params[:categoryType] = category_type if category_type.present?

      get("CategoryList/20170426", params)
    end

    def category_ranking(category_id:)
      get("CategoryRanking/20170426", categoryId: category_id)
    end

    private

    attr_reader :application_id, :access_key

    def get(path, params)
      validate_credentials!

      response = Faraday.get("#{BASE_URL}/#{path}", default_params.merge(params))
      raise RequestError, "Rakuten Recipe API request failed: #{response.status}" unless response.success?

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise RequestError, "Rakuten Recipe API response is invalid JSON: #{e.message}"
    end

    def default_params
      {
        applicationId: application_id,
        accessKey: access_key,
        format: "json",
        formatVersion: 2
      }
    end

    def validate_credentials!
      return if application_id.present? && access_key.present?

      raise MissingCredentialsError, "RAKUTEN_APPLICATION_ID and RAKUTEN_ACCESS_KEY are required"
    end
  end
end
