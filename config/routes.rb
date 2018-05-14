Rails.application.routes.draw do

  resources :chat_rooms, only: [:new, :create, :show, :index]
  #root 'chat_rooms#index'
  mount ActionCable.server => '/cable'
  resources :tweets
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], as: :finish_signup
  get "home/location_tweets"
  get "home/location_friends"

	devise_scope :user do
		authenticated :user do
			root 'chat_rooms#index', as: :authenticated_root
		end

		unauthenticated :user do
			root 'devise/sessions#new', as: :unauthenticated_root
		end
	end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
