Rails.application.routes.draw do
  # match '/auth/:provider/callback', to: 'sessions#create', via: :all
  # match 'auth/failure', to: redirect('/'), via: :all
  # match '/signout', to: 'sessions#destroy', :as => :signout, via: :all

  root to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users
  resources :sessions, only: [:new, :create, :destroy]

  get '/get_token', to: 'facebook_credential#new'
  post "/get_token", to: 'facebook_credential#create'
  get 'success', to: 'home#index'
  

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
