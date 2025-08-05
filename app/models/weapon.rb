class Weapon < Item
  enum :weapon_category, {
    one_hand_sword: "one_hand_sword",   # 片手剣
    two_hand_sword: "two_hand_sword",   # 両手剣
    dagger: "dagger",                   # 短剣
    club: "club",                       # 棍
    axe: "axe",                         # 斧
    spear: "spear",                     # 槍
    hammer: "hammer",                   # ハンマー
    staff: "staff",                     # 杖（両手杖）
    stick: "stick",                     # スティック（片手杖）
    whip: "whip",                       # ムチ
    bow: "bow",                         # 弓
    boomerang: "boomerang",             # ブーメラン
    fan: "fan",                         # 扇
    claw: "claw",                       # ツメ
    martial_arts: "martial_arts"        # 格闘（素手）
  }, validate: true

  validates :weapon_category, presence: true

  scope :one_handed, -> { where(weapon_category: %w[one_hand_sword dagger club stick whip boomerang fan claw]) }
  scope :two_handed, -> { where(weapon_category: %w[two_hand_sword axe spear hammer staff bow]) }
  scope :physical, -> { where(weapon_category: %w[one_hand_sword two_hand_sword dagger club axe spear hammer whip fan claw martial_arts]) }
  scope :magical, -> { where(weapon_category: %w[staff stick]) }
  scope :ranged, -> { where(weapon_category: %w[bow boomerang]) }
  scope :slashing, -> { where(weapon_category: %w[one_hand_sword two_hand_sword axe whip]) }
  scope :thrusting, -> { where(weapon_category: %w[dagger spear bow]) }
  scope :blunt, -> { where(weapon_category: %w[club hammer]) }

  def one_handed?
    %w[one_hand_sword dagger club stick whip boomerang fan claw].include?(weapon_category)
  end

  def two_handed?
    %w[two_hand_sword axe spear hammer staff bow].include?(weapon_category)
  end

  def can_use_left_hand?
    %w[dagger claw].include?(weapon_category)
  end

  def physical?
    %w[one_hand_sword two_hand_sword dagger club axe spear hammer whip fan claw martial_arts].include?(weapon_category)
  end

  def magical?
    %w[staff stick].include?(weapon_category)
  end

  def ranged?
    %w[bow boomerang].include?(weapon_category)
  end

  def attack_type
    case weapon_category
    when 'one_hand_sword', 'two_hand_sword', 'axe', 'whip'
      'slash'
    when 'dagger', 'spear', 'bow', 'claw'
      'thrust'
    when 'club', 'hammer'
      'blunt'
    when 'staff', 'stick'
      'magical'
    when 'boomerang', 'fan'
      'slash'
    when 'martial_arts'
      'blunt'
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