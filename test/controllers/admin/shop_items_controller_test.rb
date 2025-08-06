require "test_helper"

class Admin::ShopItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_shop_items_index_url
    assert_response :success
  end

  test "should get create" do
    get admin_shop_items_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_shop_items_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_shop_items_destroy_url
    assert_response :success
  end
end
