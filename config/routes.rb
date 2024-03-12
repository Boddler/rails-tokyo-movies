Rails.application.routes.draw do
  get "pages/home"
  get "about", to: "pages#about"
  get "update", to: "update#update"
  root to: "pages#home"
  resources :movies, only: [:show, :index, :edit, :update, :create]
  resources :cinemas, only: [:show, :index]
end
