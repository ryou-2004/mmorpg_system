Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: [ :show, :create, :destroy ]
    resource :dashboard, only: [ :show ]
    resources :users, only: [ :index, :show ]
    resources :characters, only: [ :index, :show ] do
      member do
        patch :switch_job
        patch :add_experience
      end
      resources :character_items, only: [ :index, :show ]
      resources :character_job_classes, only: [ :show ]
    end
    resources :job_classes, only: [ :index, :show, :update ]
    resources :items, only: [ :index, :show, :create, :update, :destroy ]

    resources :job_class_stats, only: [ :index, :show ]
    resources :job_level_samples, only: [ :index, :show ]
    resources :job_comparisons, only: [ :index, :create ]
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
