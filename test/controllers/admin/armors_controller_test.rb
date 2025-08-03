require "test_helper"

class Admin::ArmorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_armors_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_armors_show_url
    assert_response :success
  end
end
