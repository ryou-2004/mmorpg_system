require "test_helper"

class Admin::ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:iron_sword)
  end

  test "should get index" do
    get admin_items_url, params: { test: true }
    assert_response :success
  end

  test "should show item" do
    get admin_item_url(@item), params: { test: true }
    assert_response :success
  end

  test "should create item" do
    assert_difference('Item.count') do
      post admin_items_url, params: {
        item: {
          name: "Test Sword",
          description: "A test sword",
          item_type: "weapon",
          rarity: "common",
          max_stack: 1,
          buy_price: 100,
          sell_price: 50,
          level_requirement: 1,
          job_requirement: [],
          effects: [],
          icon_path: "test.png",
          active: true,
          sale_type: "shop"
        },
        test: true
      }
    end
    assert_response :created
  end

  test "should update item" do
    patch admin_item_url(@item), params: {
      item: { name: "Updated Sword" },
      test: true
    }
    assert_response :success
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete admin_item_url(@item), params: { test: true }
    end
    assert_response :success
  end
end
