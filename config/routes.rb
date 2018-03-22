Rails.application.routes.draw do

  resources :tweets
  #devise_for :users
  root to: "home#index"

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], as: :finish_signup

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
