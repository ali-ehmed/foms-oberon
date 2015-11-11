Rails.application.routes.draw do
  namespace :reports do
    get "/" => "base#listing"
    resources :profitability_reports, only: [:index] do
      collection do 
        get "/divisions" => "profitability_reports#divisions_report", as: :divisions
        get "/projects" => "profitability_reports#projects_report", as: :projects
        get "/project" => "profitability_reports#specified_project_report", as: :project
        get "/division_based" => "profitability_reports#specified_division_report", as: :division_based
        get "/designations" => "profitability_reports#designations_report", as: :designations
        get "/employee_history" => "profitability_reports#employee_history_report", as: :employee_history
      end
    end
    resources :re_calculate_reports, only: [:index] do
      collection do 
        post "/calculate_profitability_reports" => "re_calculate_reports#calculate_profitability_reports"
      end
    end
  end

  resources :rates, only: [:index, :create, :update] do
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
