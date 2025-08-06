require "test_helper"

class Admin::BattlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_battles_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_battles_show_url
    assert_response :success
  end

  test "should get create" do
    get admin_battles_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_battles_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_battles_destroy_url
    assert_response :success
  end
end
