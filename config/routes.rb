Rails.application.routes.draw do
  get "pages/home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root to: "pages#home"
  resources :movies, only: [:show, :index]
  resources :cinemas, only: [:show, :index]
  # Defines the root path route ("/")
  # root "articles#index"
end
