require "test_helper"

class StaticPagesTest < ActionDispatch::IntegrationTest
  test "利用規約ページを表示できる" do
    get terms_path

    assert_response :success
    assert_select "title", text: "利用規約 | KIMEAL"
    assert_select "h1", text: "利用規約"
    assert_select "h2", text: "第1条 適用"
  end

  test "プライバシーポリシーページを表示できる" do
    get privacy_path

    assert_response :success
    assert_select "title", text: "プライバシーポリシー | KIMEAL"
    assert_select "h1", text: "プライバシーポリシー"
    assert_select "h2", text: "取得する情報"
  end

  test "お問い合わせページを表示できる" do
    get contact_path

    assert_response :success
    assert_select "title", text: "お問い合わせ | KIMEAL"
    assert_select "h1", text: "お問い合わせ"
    assert_select "a[href='https://github.com/RyuYamaguchi080312/KIMEAL/issues']", text: "GitHub Issueを開く"
  end

  test "共通フッターから各ページへ遷移できる" do
    get root_path

    assert_response :success
    assert_select "footer a[href='#{terms_path}']", text: "利用規約"
    assert_select "footer a[href='#{privacy_path}']", text: "プライバシーポリシー"
    assert_select "footer a[href='#{contact_path}']", text: "お問い合わせ"
    assert_select "footer a[href='https://developers.rakuten.com/']", text: "Supported by Rakuten Developers"
  end

  test "トップ画面から各ページへ遷移できる" do
    get root_path

    assert_response :success
    assert_select "main a[href='#{terms_path}']", text: "利用規約"
    assert_select "main a[href='#{privacy_path}']", text: "プライバシーポリシー"
    assert_select "main a[href='#{contact_path}']", text: "お問い合わせ"
  end
end
