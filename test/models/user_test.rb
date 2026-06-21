require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "メールアドレスとパスワードがあれば有効である" do
    user = User.new(email: "user@example.com", password: "password")

    assert user.valid?
  end

  test "メールアドレスは必須である" do
    user = User.new(password: "password")

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "メールアドレスは一意である" do
    User.create!(email: "user@example.com", password: "password")
    user = User.new(email: "user@example.com", password: "password")

    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "パスワードは必須である" do
    user = User.new(email: "user@example.com")

    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "ロールを設定できる" do
    user = User.new(email: "user@example.com", password: "password", role: 1)

    assert user.valid?
    assert_equal 1, user.role
  end
end
