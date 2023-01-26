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

  get 'linkage_systems/:id/audience/edit', to: 'linkage_systems#audience_edit'
  post 'audience/update', to: 'linkage_systems#audience_update'

  get 'linkage_systems/:id/audience/user/new', to: 'linkage_systems#audience_user'
  post 'audience/user', to: 'linkage_systems#audience_user_create'

  post '/google/create', to: 'linkage_systems#create_google'
  put '/linkage_systems/:id/google', to: 'linkage_systems#update_google'

  get '/google_store', to: 'linkage_systems#store_google'
  get '/google_update', to: 'linkage_systems#google_update_change'

  post '/yahoo/create', to: 'linkage_systems#create_yahoo'
  get '/yahoo_store', to: 'linkage_systems#store_yahoo'

  put '/linkage_systems/:id/yahoo', to: 'linkage_systems#update_yahoo'
  get '/yahoo_update', to: 'linkage_systems#yahoo_update_change'
end
