Rails.application.routes.draw do

  root to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users
  resources :sessions, only: [:new, :create, :destroy]

  get 'store', to: 'linkage_systems#store'
  get 'change', to: 'linkage_systems#change'
  resources :linkage_systems
  put '/linkage_systems/edit', to: 'linkage_systems#update'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
