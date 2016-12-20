require 'api_constraints'
Nuryl::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,path_names: {sign_up: "registrations"} ,controllers: {sessions: 'sessions', passwords: 'passwords'}
  resources :users, only: [:show, :edit, :update ]
  # Api definition
  devise_scope :user do
    root to: "transactions#new_subscription"
    match 'api/v1/user_registration' => 'api/v1/registrations#create', :via => :post
    match 'api/v1/help' => 'api/v1/helps#create', :via => :post
    match '/api/v1/users/forget_password' => 'api/v1/passwords#create', :via => :post
    match '/api/v1/users/change_password' => 'api/v1/passwords#update_password_api', :via => :put
    match 'user_registration' => 'api/v1/registrations#new', :via => :get
    match 'registration' => 'registrations#create', :via => :post
    match  'subscribe' => 'transactions#new_subscription', :via => :get
    match 'edit_password' => 'devise/passwords#edit', :via => :get
    match 'update_password/:id' => 'devise/passwords#update', :via => :put
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
          get 'get_urls' => 'users#get_urls'
        end
      end
      resources :transactions, only: [:create] do
        collection do
          post 'subscripe' => 'transactions#create'
          get 'subscription_type' => 'transactions#get_subscription_type'
          get 'subscription_status' => 'transactions#subscription_status'
          get 'subscription_amount' => 'transactions#get_subscription_amount'
          post 'change_subscription_plan' => 'transactions#change_plan'
          post 'new_subscription' => 'transactions#new_subscription'
          post 'cancel_subscription' => 'transactions#cancel_subscription'
          post 'webhook' => 'transactions#webhook'
          put 'update_card' => 'transactions#update_card'
        end
      end
    end
  end

  resources :transactions ,only: [:new] do
    collection do
      get 'change_card_details' => 'transactions#change_card_details'
      put 'update_card' => 'transactions#update_card_details'
      post 'paypal_transaction_process' => 'transactions#paypal_transaction_process'
      post 'subscripe' => 'transactions#create'
      post 'paypal_hook' => 'transactions#paypal_hook'
    end
  end



  resources :childrens ,only: [:new, :create] do

  end


end
