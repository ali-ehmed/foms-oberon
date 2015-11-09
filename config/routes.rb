Rails.application.routes.draw do
  namespace :reports do
    get "/" => "base#listing"
    get "/divisions_report" => "profitability_reports#divisions_report"
    get "/projects_report" => "profitability_reports#projects_report"
    get "/project_report" => "profitability_reports#specified_project_report", as: :project_report
    get "/division_report" => "profitability_reports#specified_division_report", as: :division_report
    get "/designations_report" => "profitability_reports#designations_report"
    get "/employee_history_report" => "profitability_reports#employee_history_report"
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
