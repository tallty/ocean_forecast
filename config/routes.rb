Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :psdatas, only: [:index]
  
  require 'sidekiq/web'
  mount Sidekiq::Web => '/ocean/sidekiq'
  
  namespace :ocean do
    resources :nabc_hfradars, only: [:index]
  end
end
