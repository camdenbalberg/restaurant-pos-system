Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :menu_items, only: [ :index, :show ]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :employees, only: [ :index, :show ] do
        collection do
          get "by_password/:password", to: "employees#by_password"
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :inventory_items, only: [ :index, :show ]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :transactions, only: [ :index, :show ] do
        collection do
          get "by_date/:date", to: "transactions#by_date"
          get "by_employee/:employee", to: "transactions#by_employee"
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :recipes, only: [ :index, :show ]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :sale_items, only: [ :index, :show ] do
        collection do 
          get "by_transaction_id/:id", to: "sale_items#by_transaction_id"
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
