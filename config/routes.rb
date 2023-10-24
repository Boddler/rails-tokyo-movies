Rails.application.routes.draw do
  get "pages/home"
  root to: "pages#home"
  resources :movies, only: [:show, :index]
  resources :cinemas, only: [:show, :index]
end
