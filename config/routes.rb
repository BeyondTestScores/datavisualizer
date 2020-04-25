# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  resources :schools, only: [:show] do
    resources :school_tree_categories, only: [:show]
  end
  # resources :surveys, only: [:show]
  # resources :questions, only: [:show]
  # resources :categories, only: [:show]

  get 'welcome/index'
  root 'welcome#index'

  namespace :admin do
    root 'home#index'
    resources :trees do
      resources :categories, controller: 'tree_categories'
    end

    resources :schools
    resources :surveys
    resources :categories
    resources :school_tree_categories
    resources :questions
  end

end
