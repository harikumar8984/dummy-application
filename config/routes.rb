require 'api_constraints'
Nuryl::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # Api definition
  devise_scope :user do
    root to: "devise/sessions#new"
  end
  namespace :api, defaults: { format: :json },
             path: '/api'  do
    scope module: :v1 , path: '/v1',
          constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      devise_for :users
      resources :users do
        collection do
          get 'welcome_content'
          get 'validate_unique_email'
          get 'courses/:course_id/:content_type/:content_id' => 'users#get_content'
        end
      end

    end
  end
end
