Rails.application.routes.draw do

  root to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users
  resources :sessions, only: [:new, :create, :destroy]

  get 'store', to: 'linkage_systems#store'
  get 'change', to: 'linkage_systems#change'
  get '/linkage_systems/list', to: 'linkage_systems#list'
  resources :linkage_systems
  get 'linkage_systems/:id/audience/new', to: 'linkage_systems#audience_new'
  post 'audience/create', to: 'linkage_systems#audience_create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
