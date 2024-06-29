Rails.application.routes.draw do
  get "about", to: "pages#about"
  get "update", to: "update#update"
  get "latest", to: "additions#index"
  root to: "pages#home"
  resources :movies, only: [:show, :index, :edit, :update, :create] do
    member do
      patch "toggle_hide"
    end
  end
  resources :cinemas, only: [:show, :index]
  resources :showings, only: [:index]
end
