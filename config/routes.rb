require 'api_constraints'
Nuryl::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,path_names: {sign_up: "register"} ,controllers: {sessions: 'sessions'}
  # Api definition
  devise_scope :user do
    root to: "sessions#new"
    match 'api/v1/user_registration' => 'api/v1/registrations#create', :via => :post
  end

  namespace :api, defaults: { format: :json },
             path: '/api'  do
    scope module: :v1 , path: '/v1',
          constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      devise_for :users
      resources :users do
        collection do
          get 'course_content'
          get 'validate_unique_email'
          get 'courses/:course_id/:content_type/:content_id' => 'users#get_content'
          post 'courses/:course_id' => 'users#player_usage_status'
          get 'usage_statics' => 'users#send_usage_statics_info'
          get 'edit_profile' => 'users#edit_profile'
          post 'update_profile' => 'users#update_profile'
        end
      end
      resources :transactions do
        collection do
          post 'subscripe' => 'transactions#create'
          get 'subscription_amount' => 'transactions#get_subscription_amount'
          post 'change_subscription_plan' => 'transactions#change_plan'
          post 'new_subscription' => 'transactions#new_subscription'
          post 'cancel_subscription' => 'transactions#cancel_subscription'
        end
      end
    end
  end

  resources :transactions


end
