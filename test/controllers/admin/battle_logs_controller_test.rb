require "test_helper"

class Admin::BattleLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_battle_logs_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_battle_logs_show_url
    assert_response :success
  end

  test "should get create" do
    get admin_battle_logs_create_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_battle_logs_destroy_url
    assert_response :success
  end
end
