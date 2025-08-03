class Admin::CharacterJobClassesController < Admin::BaseController

  def show
    character_job_class = CharacterJobClass.includes(:character, :job_class)
                                          .find(params[:id])

    # レベル別経験値計算
    exp_to_next_level = character_job_class.exp_to_next_level
    level_progress = character_job_class.level_progress


    # 成長履歴（仮想的なデータ - 実際の実装では履歴テーブルから取得）
    level_history = (1..character_job_class.level).map do |level|
      {
        level: level,
        hp: character_job_class.job_class.base_hp + (level - 1) * character_job_class.job_class.hp_multiplier,
        mp: character_job_class.job_class.base_mp + (level - 1) * character_job_class.job_class.mp_multiplier,
        attack: character_job_class.job_class.base_attack + (level - 1) * character_job_class.job_class.attack_multiplier,
        defense: character_job_class.job_class.base_defense + (level - 1) * character_job_class.job_class.defense_multiplier
      }
    end

    render json: {
      id: character_job_class.id,
      character: {
        id: character_job_class.character.id,
        name: character_job_class.character.name
      },
      job_class: {
        id: character_job_class.job_class.id,
        name: character_job_class.job_class.name,
        job_type: character_job_class.job_class.job_type,
        max_level: character_job_class.job_class.max_level,
        description: character_job_class.job_class.description
      },
      level: character_job_class.level,
      experience: character_job_class.experience,
      skill_points: character_job_class.skill_points,
      exp_to_next_level: exp_to_next_level,
      level_progress: level_progress,
      is_current: character_job_class.character.current_character_job_class_id == character_job_class.id,
      unlocked_at: character_job_class.unlocked_at,
      stats: {
        hp: character_job_class.hp,
        max_hp: character_job_class.max_hp,
        mp: character_job_class.mp,
        max_mp: character_job_class.max_mp,
        attack: character_job_class.attack,
        defense: character_job_class.defense,
        magic_attack: character_job_class.magic_attack,
        magic_defense: character_job_class.magic_defense,
        agility: character_job_class.agility,
        luck: character_job_class.luck
      },
      level_history: level_history.last(10) # 最新10レベル分
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('messages.errors.not_found', model: I18n.t('activerecord.models.character_job_class')) }, status: :not_found
  end

  private

end