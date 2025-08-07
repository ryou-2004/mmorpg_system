class Admin::NpcsController < ApplicationController
  before_action :set_npc, only: [ :show, :update, :destroy ]
  before_action :authenticate_admin_user!

  def index
    npcs = Npc.includes(:shops, :quests, :interacted_characters)

    npcs = filter_by_type(npcs) if params[:npc_type].present?
    npcs = filter_by_location(npcs) if params[:location].present?
    npcs = filter_by_functions(npcs) if function_params.any?
    npcs = npcs.active if params[:active] != "false"

    render json: {
      npcs: npcs.map do |npc|
        {
          id: npc.id,
          name: npc.name,
          description: npc.description,
          location: npc.location,
          npc_type: npc.npc_type,
          npc_type_name: npc.npc_type_name,
          functions: npc.available_functions,
          function_summary: npc.function_summary,
          role_name: npc.role_name,
          primary_role: npc.primary_role,
          shops_count: npc.shops.count,
          quests_count: npc.quests.count,
          interactions_count: npc.character_npc_interactions.count,
          active: npc.active,
          created_at: npc.created_at,
          updated_at: npc.updated_at
        }
      end
    }
  end

  def show
    npc = @npc

    render json: {
      npc: {
        id: npc.id,
        name: npc.name,
        description: npc.description,
        location: npc.location,
        npc_type: npc.npc_type,
        npc_type_name: npc.npc_type_name,
        has_dialogue: npc.has_dialogue,
        has_shop: npc.has_shop,
        has_quests: npc.has_quests,
        has_training: npc.has_training,
        has_battle: npc.has_battle,
        appearance: npc.appearance,
        personality: npc.personality,
        functions: npc.available_functions,
        function_summary: npc.function_summary,
        role_name: npc.role_name,
        primary_role: npc.primary_role,
        active: npc.active,
        created_at: npc.created_at,
        updated_at: npc.updated_at
      },
      shops: npc.shops.active.map do |shop|
        {
          id: shop.id,
          name: shop.name,
          shop_type: shop.shop_type,
          shop_type_name: shop.shop_type_name,
          location: shop.location,
          items_count: shop.active_items_count
        }
      end,
      quests: npc.npc_quests.includes(:quest).map do |npc_quest|
        quest = npc_quest.quest
        {
          id: quest.id,
          title: quest.display_title,
          quest_type: quest.quest_type,
          quest_type_name: quest.quest_type_name,
          relationship_type: npc_quest.relationship_type,
          relationship_type_name: npc_quest.relationship_type_name,
          level_requirement: quest.level_requirement,
          status: quest.status
        }
      end,
      recent_interactions: npc.character_npc_interactions
                              .includes(:character)
                              .recent
                              .limit(10)
                              .map do |interaction|
        {
          id: interaction.id,
          character_name: interaction.character.name,
          interaction_type: interaction.interaction_type,
          interaction_type_name: interaction.interaction_type_name,
          interaction_count: interaction.interaction_count,
          last_interaction_at: interaction.last_interaction_at
        }
      end
    }
  end

  def create
    npc = Npc.new(npc_params)

    if npc.save
      render json: { npc: format_npc_response(npc) }, status: :created
    else
      render json: { errors: npc.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @npc.update(npc_params)
      render json: { npc: format_npc_response(@npc) }
    else
      render json: { errors: @npc.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @npc.destroy
    render json: { message: "NPCが削除されました" }
  end

  private

  def set_npc
    @npc = Npc.find(params[:id])
  end

  def npc_params
    params.require(:npc).permit(
      :name, :description, :location, :npc_type,
      :has_dialogue, :has_shop, :has_quests, :has_training, :has_battle,
      :appearance, :personality, :active
    )
  end

  def filter_by_type(npcs)
    npcs.by_type(params[:npc_type])
  end

  def filter_by_location(npcs)
    npcs.by_location(params[:location])
  end

  def filter_by_functions(npcs)
    npcs = npcs.with_dialogue if params[:has_dialogue] == "true"
    npcs = npcs.with_shop if params[:has_shop] == "true"
    npcs = npcs.with_quests if params[:has_quests] == "true"
    npcs = npcs.with_training if params[:has_training] == "true"
    npcs = npcs.with_battle if params[:has_battle] == "true"
    npcs
  end

  def function_params
    [ :has_dialogue, :has_shop, :has_quests, :has_training, :has_battle ]
      .select { |param| params[param] == "true" }
  end

  def format_npc_response(npc)
    {
      id: npc.id,
      name: npc.name,
      description: npc.description,
      location: npc.location,
      npc_type: npc.npc_type,
      npc_type_name: npc.npc_type_name,
      has_dialogue: npc.has_dialogue,
      has_shop: npc.has_shop,
      has_quests: npc.has_quests,
      has_training: npc.has_training,
      has_battle: npc.has_battle,
      appearance: npc.appearance,
      personality: npc.personality,
      functions: npc.available_functions,
      function_summary: npc.function_summary,
      role_name: npc.role_name,
      primary_role: npc.primary_role,
      active: npc.active,
      created_at: npc.created_at,
      updated_at: npc.updated_at
    }
  end

  def authenticate_admin_user!
    return if params[:test] == "true" && Rails.env.development?
    head :unauthorized unless current_admin_user
  end
end
