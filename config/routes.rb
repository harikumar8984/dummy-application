require 'api_constraints'
Nuryl::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,path_names: {sign_up: "register"} ,controllers: {sessions: 'sessions', passwords: 'passwords'}
  # Api definition
  devise_scope :user do
    root to: "sessions#new"
    match 'api/v1/user_registration' => 'api/v1/registrations#create', :via => :post
    match 'api/v1/help' => 'api/v1/helps#create', :via => :post
    match '/api/v1/users/forget_password' => 'api/v1/passwords#create', :via => :post
    match '/api/v1/users/change_password' => 'api/v1/passwords#update_password_api', :via => :put
    match 'user_registration' => 'api/v1/registrations#new', :via => :get
    match 'registration' => 'registrations#create', :via => :post
    match  'subscribe' => 'transactions#new_subscription', :via => :get
  end

  namespace :api, defaults: { format: :json },
             path: '/api'  do
    scope module: :v1 , path: '/v1',
          constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      devise_for :users
      resources :users ,only: [] do
        collection do
          get 'course_content'
          get 'validate_unique_email'
          get 'courses/:course_id/:content_type/:content_id' => 'users#get_content'
          post 'courses/:course_id' => 'users#player_usage_status'
          get 'usage_statics' => 'users#send_usage_statics_info'
          get 'edit_profile' => 'users#edit_profile'
          post 'update_profile' => 'users#update_profile'
          get 'subscription_mail' => 'users#send_subscription_mail'
        end
      end
      resources :transactions, only: [:create] do
        collection do
          post 'subscripe' => 'transactions#create'
          get 'subscription_amount' => 'transactions#get_subscription_amount'
          post 'change_subscription_plan' => 'transactions#change_plan'
          post 'new_subscription' => 'transactions#new_subscription'
          post 'cancel_subscription' => 'transactions#cancel_subscription'
          post 'webhook' => 'transactions#webhook'
          get 'subscription_type' => 'transactions#get_subscription_type'
          post 'in_app_purchase_details' => 'transactions#in_app_purchase_details'
          put 'in_app_deactivate_subscription' => 'transactions#cancel_in_app_subscription'
          get 'subscription_status' => 'transactions#subscription_status'
          put 'update_card' => 'transactions#update_customer'
        end
      end
    end
  end

  resources :transactions ,only: [:new] do

  end

  resources :childrens ,only: [:new, :create] do

  end


end
