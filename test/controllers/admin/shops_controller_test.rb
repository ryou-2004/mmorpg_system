require "test_helper"

class Admin::ShopsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_shops_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_shops_show_url
    assert_response :success
  end

  test "should get create" do
    get admin_shops_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_shops_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_shops_destroy_url
    assert_response :success
  end
end
