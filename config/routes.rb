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
        end
      end

    end


  end
end
