# frozen_string_literal: true

module RakutenRecipe
  # 楽天レシピAPIへのHTTPリクエストを担当する低レベルクライアント。
  # 認証情報や送信元ヘッダーの付与をこのクラスに集約し、Importer側からはAPI種別だけを意識できるようにする。
  class Client
    class MissingCredentialsError < StandardError; end
    class RequestError < StandardError; end

    BASE_URL = "https://openapi.rakuten.co.jp/recipems/api/Recipe"

    # @param application_id [String, nil] 楽天アプリID。未指定時は環境変数を参照する
    # @param access_key [String, nil] 楽天アクセスキー。未指定時は環境変数を参照する
    # @param request_origin [String, nil] 楽天APIへ送るOrigin/Refererの元URL
    def initialize(
      application_id: ENV["RAKUTEN_APPLICATION_ID"],
      access_key: ENV["RAKUTEN_ACCESS_KEY"],
      request_origin: ENV["RAKUTEN_REQUEST_ORIGIN"]
    )
      @application_id = application_id
      @access_key = access_key
      @request_origin = request_origin
    end

    # 楽天レシピAPIからカテゴリ一覧を取得する。
    #
    # @param category_type [String, nil] 楽天APIのcategoryType指定
    # @return [Hash] JSONレスポンスをHash化したもの
    # @raise [MissingCredentialsError] 認証情報が不足している場合
    # @raise [RequestError] APIリクエストまたはJSON解析に失敗した場合
    def category_list(category_type: nil)
      params = {}
      params[:categoryType] = category_type if category_type.present?

      get("CategoryList/20170426", params)
    end

    # 指定カテゴリのランキングレシピを取得する。
    #
    # @param category_id [String] 楽天APIへ渡すカテゴリID
    # @return [Hash] JSONレスポンスをHash化したもの
    # @raise [MissingCredentialsError] 認証情報が不足している場合
    # @raise [RequestError] APIリクエストまたはJSON解析に失敗した場合
    def category_ranking(category_id:)
      get("CategoryRanking/20170426", categoryId: category_id)
    end

    private

    attr_reader :application_id, :access_key, :request_origin

    def get(path, params)
      validate_credentials!

      response = Faraday.get("#{BASE_URL}/#{path}", default_params.merge(params), request_headers)
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

    def request_headers
      return {} if normalized_request_origin.blank?

      # Webアプリケーション設定の楽天APIでは、許可済みサイト判定のために送信元ヘッダーが必要になる。
      {
        "Origin" => normalized_request_origin,
        "Referer" => "#{normalized_request_origin}/"
      }
    end

    def normalized_request_origin
      request_origin.to_s.chomp("/")
    end

    def validate_credentials!
      return if application_id.present? && access_key.present?

      raise MissingCredentialsError, "RAKUTEN_APPLICATION_ID and RAKUTEN_ACCESS_KEY are required"
    end
  end
end
