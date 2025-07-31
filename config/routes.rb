Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: [ :show, :create, :destroy ]
    resource :dashboard, only: [ :show ]
    resources :users, only: [ :index, :show ]
    resources :players, only: [ :index, :show ] do
      member do
        patch :switch_job
        patch :add_experience
      end
    end
    resources :job_classes, only: [ :index, :show, :update ]
    resources :items, only: [ :index, :show, :create, :update, :destroy ]
  end

  namespace :api do
    namespace :v1 do
      resources :players, only: [ :show ] do
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

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
