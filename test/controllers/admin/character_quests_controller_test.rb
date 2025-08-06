require "test_helper"

class Admin::CharacterQuestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_character_quests_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_character_quests_show_url
    assert_response :success
  end

  test "should get create" do
    get admin_character_quests_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_character_quests_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_character_quests_destroy_url
    assert_response :success
  end
end
