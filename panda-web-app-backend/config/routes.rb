Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :menu_items, only: [ :index, :show ]
      post '/menu_items/add_menu_item', to: 'menu_items#add_menu_item'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :employees, only: [ :index, :show ]
      post '/employees/add_employee', to: 'employees#add_employee'
      delete '/employees/delete_employee/:id', to: 'employees#delete_employee'
      put '/employees/edit_employee/:id', to: 'employees#edit_employee'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :employees, only: [ :index, :show ] do
        collection do
          get "by_password/:password", to: "employees#by_password"
          get "by_employee_id/:employee_id", to: "employees#by_employee_id"
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
      resources :transactions do
        collection do
          get "by_date/:date", to: "transactions#by_date"
          get "by_employee/:employee", to: "transactions#by_employee"
        end
        member do
          patch :toggle_completed
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :recipes, only: [ :index, :show ]
      post '/recipes/add_recipe', to: 'recipes#add_recipe'
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
