# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :tools
    resources :auth_servers

    root to: 'tools#index'
  end

  get '/launch/:tool_client_id', to: 'launches#show', as: :launch
  get '/callback', to: 'launches#callback', as: :launch_callback
end
