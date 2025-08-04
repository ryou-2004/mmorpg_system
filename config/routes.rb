Rails.application.routes.draw do
  namespace :admin do
    resources :weapons, only: [:index, :show, :create, :update, :destroy]
    resources :armors, only: [:index, :show, :create, :update, :destroy]
    resource :session, only: [ :show, :create, :destroy ]
    resource :dashboard, only: [ :show ]
    resources :users, only: [ :index, :show ]
    
    namespace :characters do
      resources :equipments, only: [ :index ]
    end
    
    resources :characters, only: [ :index, :show ] do
      member do
        patch :switch_job
        patch :add_experience
      end
      resources :character_items, only: [ :index, :show ] do
        member do
          patch :move_to_inventory
          patch :move_to_warehouse
          patch :use_item
        end
      end
      resources :character_job_classes, only: [ :show ]
      resource :equipment, only: [], controller: 'character_equipment' do
        get :index
        post :equip
        post :unequip
      end
    end
    resources :job_classes, only: [ :index, :show, :update ] do
      member do
        get :skill_lines
        get :skill_statistics
        get 'skill_lines/:skill_line_id', to: 'job_classes#skill_line', as: :skill_line
      end
    end
    resources :items, only: [ :index, :show, :create, :update, :destroy ]

    resources :job_class_stats, only: [ :index, :show ]
    resources :job_level_samples, only: [ :index, :show ]
    resources :job_comparisons, only: [ :index, :create ]

    # スキルシステム関連
    resources :skill_lines, only: [ :index, :show, :create, :update, :destroy ] do
      resources :skill_nodes, only: [ :index, :show, :create, :update, :destroy ]
    end
    
    resources :characters, only: [] do
      resources :character_skills, only: [ :index, :show ] do
        member do
          post :invest_points
          post :reset_points
          post :add_skill_points
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :characters, only: [ :show ] do
        member do
          patch :switch_job
          patch :add_experience
        end
      end
      resources :job_classes, only: [ :index, :show ] do
        member do
          get :calculate_stats
        end
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
