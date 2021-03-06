SampleApp::Application.routes.draw do
  resources :projects do
    resources :tasks do
      post :change_status
      post :calculate
    end
    resource :task do
      post :calculate
      post :sort
    end
  end
  resources :users do
    member do
      get :following, :followers
      # users_controllerにメソッドを書く
      post :upload_image
    end
  end
  resources :sessions,      only: [:new, :create, :destroy]
  resources :tasks,    only: [:create, :destroy] do
    post :start
    post :finish
  end
  resources :relationships, only: [:create, :destroy]
  root to: 'static_pages#home'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
end
