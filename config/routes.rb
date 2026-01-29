Rails.application.routes.draw do
  devise_for :users

  root 'welcome#index'

  # Search
  resource :search, only: [:show, :create]

  # Tickets
  resources :tickets, except: [:edit, :update]

  # Vehicles and seats
  resources :vehicles, only: [:show] do
    resources :seats, only: [:index]
  end

  # Cart and checkout
  resource :cart, only: [:show] do
    post :add_item
    delete :remove_item
    post :checkout
  end

  # Orders
  resources :orders, only: [:index, :show, :new, :create]

  # Profile
  resource :profile, only: [:show, :edit, :update] do
    get :trips
    get :upcoming
  end

  # Favorite routes
  resources :favorite_routes, only: [:index, :create, :destroy]

  # Seat selection
  post 'seats/:id/select', to: 'seats#select', as: :select_seat
  delete 'seats/:id/release', to: 'seats#release', as: :release_seat

  # Admin namespace
  namespace :admin do
    resources :dashboards, only: [:index]
    resources :statistics, only: [:index]

    # Legacy railway stations (for backwards compatibility)
    resources :railway_stations do
      patch :update_position, on: :member
      patch :update_time, on: :member
    end

    # New unified stations
    resources :stations do
      patch :update_position, on: :member
      patch :update_time, on: :member
    end

    resources :routes

    # Legacy trains
    resources :trains do
      resources :carriages, shallow: true
    end

    # New unified vehicles
    resources :vehicles do
      resources :compartments, shallow: true do
        resources :seats, only: [:index]
      end
    end

    resources :tickets
    resources :orders, only: [:index, :show, :update]
  end

  # API namespace
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      post 'auth/refresh', to: 'auth#refresh'

      # Search
      resources :searches, only: [:create]

      # Vehicles and seats
      resources :vehicles, only: [:index, :show] do
        resources :seats, only: [:index]
      end

      # Cart
      resource :cart, only: [:show] do
        post :add_item
        delete :remove_item
        post :checkout
      end

      # Orders
      resources :orders, only: [:index, :show, :create]

      # Profile
      resource :profile, only: [:show, :update] do
        get :trips
        get :upcoming
      end

      # Favorites
      resources :favorite_routes, only: [:index, :create, :destroy]
    end
  end
end
