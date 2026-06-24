require "test_helper"
require "minitest/mock"

class RakutenRecipeClientTest < ActiveSupport::TestCase
  test "カテゴリ別ランキングAPIへcategoryId付きでリクエストする" do
    response = Struct.new(:success?, :status, :body).new(true, 200, { result: [] }.to_json)
    requests = []

    Faraday.stub(:get, ->(url, params) {
      requests << [url, params]
      response
    }) do
      result = RakutenRecipe::Client.new(
        application_id: "app-id",
        access_key: "access-key"
      ).category_ranking(category_id: "10-69-45")

      assert_equal({ "result" => [] }, result)
    end

    url, params = requests.first
    assert_equal "https://openapi.rakuten.co.jp/recipems/api/Recipe/CategoryRanking/20170426", url
    assert_equal "10-69-45", params[:categoryId]
    assert_equal "app-id", params[:applicationId]
    assert_equal "access-key", params[:accessKey]
    assert_equal 2, params[:formatVersion]
  end

  test "認証情報がない場合はリクエストしない" do
    assert_raises RakutenRecipe::Client::MissingCredentialsError do
      RakutenRecipe::Client.new(application_id: nil, access_key: nil).category_list
    end
  end
end
