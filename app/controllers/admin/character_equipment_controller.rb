class Admin::CharacterEquipmentController < Admin::BaseController
  before_action :set_character

  def index
    equipped_items = @character.equipped_items.includes(:item)
    
    # 装備スロット別にグループ化
    equipment_by_slot = {}
    CharacterItem::EQUIPMENT_SLOTS.keys.each do |slot|
      equipment_by_slot[slot] = equipped_items.find { |ci| ci.equipment_slot == slot }
    end
    
    # 合計ステータス計算
    current_job_class = @character.current_character_job_class
    total_stats = if current_job_class
      {
        hp: current_job_class.hp,
        max_hp: current_job_class.max_hp,
        mp: current_job_class.mp,
        max_mp: current_job_class.max_mp,
        attack: current_job_class.attack,
        defense: current_job_class.defense,
        magic_attack: current_job_class.magic_attack,
        magic_defense: current_job_class.magic_defense,
        agility: current_job_class.agility,
        luck: current_job_class.luck
      }
    else
      {}
    end

    render json: {
      character: {
        id: @character.id,
        name: @character.name,
        current_job: current_job_class ? {
          id: current_job_class.job_class.id,
          name: current_job_class.job_class.name,
          level: current_job_class.level,
          can_equip_left_hand: current_job_class.job_class.can_equip_left_hand
        } : nil
      },
      equipment_slots: CharacterItem::EQUIPMENT_SLOTS,
      equipped_items: equipment_by_slot.transform_values do |character_item|
        if character_item
          {
            id: character_item.id,
            item: {
              id: character_item.item.id,
              name: character_item.item.name,
              description: character_item.item.description,
              item_type: character_item.item.item_type,
              rarity: character_item.item.rarity,
              effects: character_item.item.effects,
              icon_path: character_item.item.icon_path
            },
            quantity: character_item.quantity,
            enchantment_level: character_item.enchantment_level,
            durability: character_item.durability,
            max_durability: character_item.max_durability,
            equipment_slot: character_item.equipment_slot
          }
        else
          nil
        end
      end,
      total_stats: total_stats,
      available_items: available_equipment_items
    }
  end

  def equip
    character_item = @character.character_items.find(params[:character_item_id])
    slot = params[:slot]
    
    unless CharacterItem::EQUIPMENT_SLOTS.key?(slot)
      return render json: { error: "無効な装備スロットです" }, status: :bad_request
    end
    
    unless character_item.can_equip_to_slot?(slot)
      return render json: { error: "このアイテムはその装備スロットに装備できません" }, status: :bad_request
    end
    
    # 職業制限チェック
    current_job = @character.current_character_job_class&.job_class
    if current_job && character_item.item.job_requirement.present?
      unless character_item.item.job_requirement.include?(current_job.name)
        return render json: { error: "現在の職業では装備できません" }, status: :bad_request
      end
    end
    
    # レベル制限チェック
    current_level = @character.current_character_job_class&.level || 1
    if character_item.item.level_requirement > current_level
      return render json: { 
        error: "レベルが足りません (必要: Lv.#{character_item.item.level_requirement})" 
      }, status: :bad_request
    end
    
    if @character.equip_item!(character_item, slot)
      # 最新の装備状態とステータスを取得
      equipped_items = @character.equipped_items.includes(:item)
      equipment_by_slot = {}
      CharacterItem::EQUIPMENT_SLOTS.keys.each do |slot_key|
        equipment_by_slot[slot_key] = equipped_items.find { |ci| ci.equipment_slot == slot_key }
      end

      current_job_class = @character.current_character_job_class
      total_stats = if current_job_class
        {
          hp: current_job_class.hp,
          max_hp: current_job_class.max_hp,
          mp: current_job_class.mp,
          max_mp: current_job_class.max_mp,
          attack: current_job_class.attack,
          defense: current_job_class.defense,
          magic_attack: current_job_class.magic_attack,
          magic_defense: current_job_class.magic_defense,
          agility: current_job_class.agility,
          luck: current_job_class.luck
        }
      else
        {}
      end

      render json: { 
        success: true, 
        message: "#{character_item.item.name}を装備しました",
        equipped_item: format_character_item(character_item.reload),
        total_stats: total_stats,
        equipped_items: equipment_by_slot.transform_values do |character_item|
          character_item ? format_character_item(character_item) : nil
        end
      }
    else
      render json: { error: "装備に失敗しました" }, status: :unprocessable_entity
    end
  end

  def unequip
    character_item = @character.character_items.equipped_items.find(params[:character_item_id])
    
    if @character.unequip_item!(character_item)
      # 最新の装備状態とステータスを取得
      equipped_items = @character.equipped_items.includes(:item)
      equipment_by_slot = {}
      CharacterItem::EQUIPMENT_SLOTS.keys.each do |slot_key|
        equipment_by_slot[slot_key] = equipped_items.find { |ci| ci.equipment_slot == slot_key }
      end

      current_job_class = @character.current_character_job_class
      total_stats = if current_job_class
        {
          hp: current_job_class.hp,
          max_hp: current_job_class.max_hp,
          mp: current_job_class.mp,
          max_mp: current_job_class.max_mp,
          attack: current_job_class.attack,
          defense: current_job_class.defense,
          magic_attack: current_job_class.magic_attack,
          magic_defense: current_job_class.magic_defense,
          agility: current_job_class.agility,
          luck: current_job_class.luck
        }
      else
        {}
      end

      render json: { 
        success: true, 
        message: "#{character_item.item.name}を解除しました",
        total_stats: total_stats,
        equipped_items: equipment_by_slot.transform_values do |character_item|
          character_item ? format_character_item(character_item) : nil
        end
      }
    else
      render json: { error: "装備解除に失敗しました" }, status: :unprocessable_entity
    end
  end

  private

  def set_character
    @character = Character.includes(
      :current_character_job_class, 
      character_items: :item
    ).find(params[:character_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "キャラクターが見つかりません" }, status: :not_found
  end

  def available_equipment_items
    @character.character_items
              .joins(:item)
              .where(location: ["inventory", "warehouse"])
              .where(items: { item_type: ["weapon", "armor", "accessory"] })
              .character_accessible
              .includes(:item)
              .map { |ci| format_character_item(ci) }
  end

  def format_character_item(character_item)
    {
      id: character_item.id,
      item: {
        id: character_item.item.id,
        name: character_item.item.name,
        description: character_item.item.description,
        item_type: character_item.item.item_type,
        rarity: character_item.item.rarity,
        level_requirement: character_item.item.level_requirement,
        job_requirement: character_item.item.job_requirement,
        effects: character_item.item.effects,
        icon_path: character_item.item.icon_path
      },
      quantity: character_item.quantity,
      enchantment_level: character_item.enchantment_level,
      durability: character_item.durability,
      max_durability: character_item.max_durability,
      location: character_item.location,
      equipment_slot: character_item.equipment_slot
    }
  end
end