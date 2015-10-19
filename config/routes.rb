require 'api_constraints'
Nuryl::Application.routes.draw do
  devise_for :users
  # Api definition
  namespace :api, defaults: { format: :json },
            constraints: { subdomain: 'api' }, path: '/'  do
    scope module: :v1 , path: '/v1',
          constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      devise_for :users
    end
  end
end
