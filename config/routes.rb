Rails.application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create', via: :all
  match 'auth/failure', to: redirect('/'), via: :all
  match '/signout', to: 'sessions#destroy', :as => :signout, via: :all

  get '/login', to: 'sessions#new'
  post "/login", to: 'sessions#create'
  get 'success', to: 'home#index'
  get 'token', to: 'home#token'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
