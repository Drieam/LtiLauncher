# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :tools
    resources :auth_servers

    root to: 'tools#index'
  end

  namespace :api, defaults: { format: 'json' }, constraints: { format: 'json' } do
    namespace :v1 do
      resources :auth_servers, only: [] do
        resources :tools, only: :index
      end
    end
  end

  get '/launch/:tool_client_id', to: 'launches#show', as: :launch
  get '/callback', to: 'launches#callback', as: :launch_callback
  get '/auth', to: 'launches#auth', format: :html
  post '/oauth2/token', to: 'oauth2_tokens#create', format: :json
  resources :keypairs, only: :index, format: :json
end
