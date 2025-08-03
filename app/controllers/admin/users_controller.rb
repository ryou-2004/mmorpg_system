class Admin::UsersController < Admin::BaseController

  def index
    users = User.left_joins(:characters)
                .select("users.*, COUNT(characters.id) as character_count")
                .group("users.id")
                .order(created_at: :desc)

    render json: {
      data: users.map do |user|
        {
          id: user.id,
          username: user.name,
          email: user.email,
          created_at: user.created_at,
          last_login_at: user.last_login_at,
          character_count: user.character_count.to_i,
          is_active: user.active
        }
      end
    }
  end

  def show
    user = User.includes(characters: { character_job_classes: :job_class, current_character_job_class: :job_class })
               .find(params[:id])

    render json: {
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        active: user.active,
        created_at: user.created_at,
        last_login_at: user.last_login_at,
        characters: user.characters.map do |character|
          {
            id: character.id,
            name: character.name,
            gold: character.gold,
            active: character.active,
            created_at: character.created_at,
            last_login_at: character.last_login_at,
            current_job: character.current_character_job_class ? {
              id: character.current_character_job_class.job_class.id,
              name: character.current_character_job_class.job_class.name,
              job_type: character.current_character_job_class.job_class.job_type,
              level: character.current_character_job_class.level,
              experience: character.current_character_job_class.experience
            } : nil,
            job_classes: character.character_job_classes.map do |cjc|
              {
                id: cjc.job_class.id,
                name: cjc.job_class.name,
                job_type: cjc.job_class.job_type,
                level: cjc.level,
                experience: cjc.experience,
                unlocked_at: cjc.unlocked_at
              }
            end
          }
        end
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('messages.errors.not_found', model: I18n.t('activerecord.models.user')) }, status: :not_found
  end
end
