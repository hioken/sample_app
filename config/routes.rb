Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  delete '/users/destroy_not_activated', to: 'users#destroy_not_activated', as: 'destroy_not_activated'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets, only: %i[new create edit update]
  resources :microposts, only: %i[create destroy]
  get '/microposts', to: 'static_pages#home'
  resources :relationships, only: %i[create destroy]
  resources :channels, only: %i[index show create]
  post '/add_user', to: 'channels#add_user', as: :add_user

end

  # mount Rails::Importmap::Engine, at: 'rails/importmap'