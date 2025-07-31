require "test_helper"

class PlayerStatTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    player_stat = player_stats(:player_one_stats)
    assert player_stat.valid?
  end

  test "should require player" do
    player_stat = PlayerStat.new(level: 1, experience: 0, hp: 100, max_hp: 100, mp: 50, max_mp: 50, attack: 10, defense: 10, magic_attack: 10, magic_defense: 10, agility: 10, luck: 10, stat_points: 0)
    assert_not player_stat.valid?
    assert_includes player_stat.errors[:player], "must exist"
  end

  test "should calculate battle power correctly" do
    player_stat = player_stats(:player_one_stats)
    expected_power = (player_stat.attack + player_stat.defense + player_stat.magic_attack + player_stat.magic_defense + player_stat.agility + player_stat.luck) * player_stat.level / 6
    assert_equal expected_power, player_stat.battle_power
  end

  test "should heal correctly" do
    player_stat = player_stats(:player_one_stats)
    player_stat.update!(hp: 50) # Set HP to 50 out of 120

    healed = player_stat.heal(30)
    assert_equal 30, healed
    assert_equal 80, player_stat.hp
  end

  test "should not heal beyond max HP" do
    player_stat = player_stats(:player_one_stats)
    player_stat.update!(hp: 100) # Set HP to 100 out of 120

    healed = player_stat.heal(50)
    assert_equal 20, healed # Should only heal 20 to reach max
    assert_equal 120, player_stat.hp
  end

  test "should calculate exp to next level" do
    player_stat = player_stats(:player_one_stats)
    # Player is level 2 with 150 exp, needs 250 for level 3
    expected_exp_needed = 250 - 150
    assert_equal expected_exp_needed, player_stat.exp_to_next_level
  end

  test "should check if can level up" do
    player_stat = player_stats(:player_two_stats)
    # Player is level 3 with 300 exp, needs 450 for level 4
    assert_not player_stat.can_level_up?

    player_stat.update!(experience: 450)
    assert player_stat.can_level_up?
  end
end
