Rails.application.routes.draw do
  resources :questions
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :categories, only: [:show]
  get 'welcome/index'
  root 'welcome#index'

  namespace :admin do
    root 'home#index'
    resources :categories
    resources :questions
  end

end
