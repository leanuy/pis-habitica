# frozen_string_literal: true

Rails.application.routes.draw do
  resources :memberships
  post 'user_token' => 'user_token#create'
  resources :types
  resources :users do
    resources :habits, only: %i[show index]
  end
  resources :characters
  namespace :me do
    get '', to: 'users#home'
    resources :notifications
    resources :characters
    resources :requests
    resources :friends, controller: 'friends'
    resources :habits do
      member do
        post 'fulfill', to: 'habits#fulfill'
        get 'stat', to: 'habits#stat_habit'
        delete 'fulfill', to: 'habits#undo_habit'
      end
    end

    resources :groups do
      member do
        post 'habits', to: 'groups#add_habits'
        get 'habits', to: 'groups#view_habits'
      end
      resources :habits do
        member do
          post 'fulfill', to: 'habits#fulfill'
        end
      end
    end

    post 'requests/:id', to: 'requests#add_friend'
  end
  # - FOR DEVELOPMENT ONLY
  get '/killme', to: 'users#killme'
  # For details on the DSL available wihthin this file, see http://guides.rubyonrails.org/routing.htm
end
