Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "auth/:provider/callback", to: "sessions#google_auth"
  post "auth/login", to: "sessions#login_traditional"
  get "auth/:provider", to: redirect("/auth/google_oauth2")
  post "auth/failure", to: redirect("/login")
  post "auth/logout", to: "sessions#logout"

  namespace :api do
    namespace :v1 do
      get "/verify/token", to: "auths#validate_token"
    end
  end

  namespace :api do
    namespace :v1 do
      post 'lock_screen', to: 'screens#lock'
      post 'unlock_screen', to: 'screens#unlock'
      get 'screen_status', to: 'screens#status'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :menu_items, only: [ :index, :show ] do
        member do
          patch :update_image
        end
      end
      post '/menu_items/add_menu_item', to: 'menu_items#add_menu_item'
      delete '/menu_items/:menu_id', to: 'menu_items#destroy'
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
      resources :inventory_items do
        collection do
          post '/create', to: 'inventory_items#create'
          put '/:id', to: 'inventory_items#update'
          delete '/:id', to: 'inventory_items#destroy'
        end
        member do
          patch '/update_stock', to: 'inventory_items#update_stock'
        end
      end
    end
  end


namespace :api do
  namespace :v1 do
    resources :menu_items do
      member do
        patch :update_image
      end
      collection do
        post '/create', to: 'menu_items#create'
        put '/:id', to: 'menu_items#update'
        delete '/:id', to: 'menu_items#destroy'
      end
    end
  end
end

namespace :api do
  namespace :v1 do
    resources :recipes do
      collection do
        post '/create', to: 'recipes#create'
        put '/:menu_id/:inv_id', to: 'recipes#update'
        delete '/:menu_id/:inv_id', to: 'recipes#destroy'
      end
    end
  end
end

  namespace :api do
    namespace :v1 do
      resources :transactions do
        collection do
          get "by_date/:date", to: "transactions#by_date"
          get "by_employee/:employee", to: "transactions#by_employee"
          get "by_date_range", to: "transactions#by_date_range"
          get :highest_transaction_id, to: "transactions#highest_transaction_id" # Fix: Add this here
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
      post "/recipes/add_recipe", to: "recipes#add_recipe"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :sale_items, only: [ :index, :show ] do
        collection do
          get "by_transaction_id/:id", to: "sale_items#by_transaction_id"
          post 'by_transaction_id', to: 'sale_items#by_transaction_id'
          post 'by_transaction_ids', to: 'sale_items#by_transaction_ids'
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :sale_items, only: [ :index, :show ]
      post '/sale_items/add_sale_item', to: 'sale_items#add_sale_item'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :customers, only: [ :index, :show ] do
        collection do
          get 'by_phone/:phone', to: 'customers#by_phone'
        end
      end
    end
  end
  
  namespace :api do
    namespace :v1 do
      resources :customers, only: [ :index, :show ]
      post "/customers/add_customer", to: "customers#add_customer"
      put '/customers/add_points/:id', to: 'customers#add_points'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :transactions, only: [ :index, :show ]
      post '/transactions/add_transaction', to: 'transactions#add_transaction'
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
