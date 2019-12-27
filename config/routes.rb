# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :tools
    resources :auth_servers

    root to: 'tools#index'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
