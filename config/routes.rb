Rails.application.routes.draw do
  get "pages/home"
  get "about", to: "pages#about"
  root to: "pages#home"
  resources :movies, only: [:show, :index]
  resources :cinemas, only: [:show, :index]
end
