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
      resources :categories, controller: 'tree_categories' do
        resources :questions, controller: 'tree_category_questions'
      end
    end

    resources :schools
    resources :surveys, only: [:show, :edit, :update]
    resources :school_tree_categories
  end

  post '/survey_responses', to: 'admin/survey_responses#create'
end
