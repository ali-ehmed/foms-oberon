Rails.application.routes.draw do
  resources :rates, only: [:index] do
    put "/:designation_id/update" => "rates#update", on: :collection, as: :update
    get "/sync_designations" => "rates#sync_designations", on: :collection
    get "/:designation_id/designation_rate_history" => "rates#designation_rate_history", on: :collection
  end

  resources :projects, only: [:index] do
    get "/sync_projects" => "projects#sync_projects", on: :collection
  end

  devise_for :users
  get 'home/welcome'

  authenticated :user do
    root 'home#welcome', as: :authenticated_root
  end

  unauthenticated :user do
    devise_scope :user do 
      get "/", to: "devise/sessions#new"
    end
  end
end
