require "test_helper"
require "minitest/mock"

class RakutenRecipeClientTest < ActiveSupport::TestCase
  test "カテゴリ別ランキングAPIへcategoryId付きでリクエストする" do
    response = Struct.new(:success?, :status, :body).new(true, 200, { result: [] }.to_json)
    requests = []

    Faraday.stub(:get, ->(url, params, headers = {}) {
      requests << [url, params, headers]
      response
    }) do
      result = RakutenRecipe::Client.new(
        application_id: "app-id",
        access_key: "access-key"
      ).category_ranking(category_id: "10-69-45")

      assert_equal({ "result" => [] }, result)
    end

    url, params, headers = requests.first
    assert_equal "https://openapi.rakuten.co.jp/recipems/api/Recipe/CategoryRanking/20170426", url
    assert_equal "10-69-45", params[:categoryId]
    assert_equal "app-id", params[:applicationId]
    assert_equal "access-key", params[:accessKey]
    assert_equal 2, params[:formatVersion]
    assert_empty headers
  end

  test "送信元URLがある場合はOriginとRefererを付けてリクエストする" do
    response = Struct.new(:success?, :status, :body).new(true, 200, { result: [] }.to_json)
    requests = []

    Faraday.stub(:get, ->(url, params, headers = {}) {
      requests << [url, params, headers]
      response
    }) do
      RakutenRecipe::Client.new(
        application_id: "app-id",
        access_key: "access-key",
        request_origin: "https://kimeal-staging.onrender.com/"
      ).category_list
    end

    _url, _params, headers = requests.first
    assert_equal "https://kimeal-staging.onrender.com", headers["Origin"]
    assert_equal "https://kimeal-staging.onrender.com/", headers["Referer"]
  end

  test "認証情報がない場合はリクエストしない" do
    assert_raises RakutenRecipe::Client::MissingCredentialsError do
      RakutenRecipe::Client.new(application_id: nil, access_key: nil).category_list
    end
  end
end
