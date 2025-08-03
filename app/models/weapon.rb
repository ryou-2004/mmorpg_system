class Weapon < Item
  enum :weapon_category, {
    one_hand_sword: "one_hand_sword",   # 片手剣
    two_hand_sword: "two_hand_sword",   # 両手剣
    dagger: "dagger",                   # 短剣
    club: "club",                       # 棍
    axe: "axe",                         # 斧
    spear: "spear",                     # 槍
    hammer: "hammer",                   # ハンマー
    staff: "staff",                     # 杖
    whip: "whip",                       # ムチ
    bow: "bow",                         # 弓
    boomerang: "boomerang"              # ブーメラン
  }, validate: true

  validates :weapon_category, presence: true

  scope :one_handed, -> { where(weapon_category: %w[one_hand_sword dagger club staff whip boomerang]) }
  scope :two_handed, -> { where(weapon_category: %w[two_hand_sword axe spear hammer bow]) }
  scope :physical, -> { where(weapon_category: %w[one_hand_sword two_hand_sword dagger club axe spear hammer whip]) }
  scope :magical, -> { where(weapon_category: %w[staff]) }
  scope :ranged, -> { where(weapon_category: %w[bow boomerang]) }
  scope :slashing, -> { where(weapon_category: %w[one_hand_sword two_hand_sword axe whip]) }
  scope :thrusting, -> { where(weapon_category: %w[dagger spear bow]) }
  scope :blunt, -> { where(weapon_category: %w[club hammer]) }

  def one_handed?
    %w[one_hand_sword dagger club staff whip boomerang].include?(weapon_category)
  end

  def two_handed?
    %w[two_hand_sword axe spear hammer bow].include?(weapon_category)
  end

  def can_use_left_hand?
    %w[dagger].include?(weapon_category)
  end

  def physical?
    %w[one_hand_sword two_hand_sword dagger club axe spear hammer whip].include?(weapon_category)
  end

  def magical?
    %w[staff].include?(weapon_category)
  end

  def ranged?
    %w[bow boomerang].include?(weapon_category)
  end

  def attack_type
    case weapon_category
    when 'one_hand_sword', 'two_hand_sword', 'axe', 'whip'
      'slash'
    when 'dagger', 'spear', 'bow'
      'thrust'
    when 'club', 'hammer'
      'blunt'
    when 'staff'
      'magical'
    when 'boomerang'
      'slash'
    else
      'physical'
    end
  end

  def weapon_category_name
    I18n.t("weapons.categories.#{weapon_category}", default: weapon_category)
  end

  def attack_type_name
    I18n.t("weapons.attack_types.#{attack_type}", default: attack_type)
  end

  def equipment_slot
    can_use_left_hand? ? I18n.t('equipment_slots.left_hand') : I18n.t('equipment_slots.right_hand')
  end
end