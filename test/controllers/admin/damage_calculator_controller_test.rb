require "test_helper"

class Admin::DamageCalculatorControllerTest < ActionDispatch::IntegrationTest
  test "should get verify" do
    get admin_damage_calculator_verify_url
    assert_response :success
  end

  test "should get simulate" do
    get admin_damage_calculator_simulate_url
    assert_response :success
  end

  test "should get analyze" do
    get admin_damage_calculator_analyze_url
    assert_response :success
  end
end
