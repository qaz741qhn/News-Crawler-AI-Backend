Rails.application.routes.draw do
  resources :news, only: [:index, :show]
  resources :visits, only: [:create]
end
