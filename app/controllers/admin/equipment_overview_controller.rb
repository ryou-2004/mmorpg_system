class Admin::EquipmentOverviewController < Admin::BaseController

  def index
    characters = Character.includes(
      :user,
      :current_character_job_class,
      character_items: [:item]
    ).where(active: true)
    
    # フィルタリング
    if params[:character_name].present?
      characters = characters.where("characters.name ILIKE ?", "%#{params[:character_name]}%")
    end
    
    if params[:job_class_id].present?
      characters = characters.joins(current_character_job_class: :job_class)
                           .where(job_classes: { id: params[:job_class_id] })
    end
    
    if params[:missing_equipment].present?
      slot = params[:missing_equipment]
      if CharacterItem::EQUIPMENT_SLOTS.key?(slot)
        characters = characters.left_joins(:character_items)
                             .where.not(character_items: { equipment_slot: slot, location: "equipped" })
                             .or(characters.where(character_items: { id: nil }))
      end
    end

    characters = characters.order(:id).limit(100) # パフォーマンス制限

    render json: {
      data: characters.map do |character|
        equipped_items = character.character_items.equipped_items.includes(:item)
        equipment_by_slot = {}
        
        CharacterItem::EQUIPMENT_SLOTS.each do |slot, slot_name|
          equipped_item = equipped_items.find { |ci| ci.equipment_slot == slot }
          equipment_by_slot[slot] = equipped_item ? {
            id: equipped_item.id,
            name: equipped_item.item.name,
            rarity: equipped_item.item.rarity,
            enchantment_level: equipped_item.enchantment_level,
            durability: equipped_item.durability,
            max_durability: equipped_item.max_durability
          } : nil
        end
        
        {
          id: character.id,
          name: character.name,
          current_job: character.current_character_job_class ? {
            id: character.current_character_job_class.job_class.id,
            name: character.current_character_job_class.job_class.name,
            level: character.current_character_job_class.level
          } : nil,
          equipment: equipment_by_slot,
          equipped_count: equipped_items.count,
          empty_slots: CharacterItem::EQUIPMENT_SLOTS.size - equipped_items.count
        }
      end,
      meta: {
        total_characters: characters.count,
        equipment_slots: CharacterItem::EQUIPMENT_SLOTS,
        available_job_classes: JobClass.active.select(:id, :name).order(:name).map { |jc| { id: jc.id, name: jc.name } },
        filters: {
          character_name: params[:character_name],
          job_class_id: params[:job_class_id],
          missing_equipment: params[:missing_equipment]
        }
      }
    }
  end

end