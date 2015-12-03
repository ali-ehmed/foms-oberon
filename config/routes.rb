Rails.application.routes.draw do
  resources :invoices, only: [:index, :update] do
    collection do
      get "invoice_number" => "invoices#get_invoice_number"
      get "synchronisation_of_invoices" => "invoices#synchronisation_of_invoices"
      post "fetch_invoices" => "invoices#fetch_invoices"
      post "custom_invoice" => "invoices#custom_invoice"
      get "new_employee" => "invoices#unregistered_employee"
      get "resync_status" => "invoices#resync_status"
      post "generate_invoices" => "invoices#generate_invoices", :as => :generate
      put "/recalculate" => "invoices#recalculate"
      get "/status", to: "invoices#invoice_status"
    end
  end

  match "invoices/:invoice_created_date" => "invoices#show", via: [:get, :pdf], :as => :invoice_pdf

  resources :employees, :only => [:create] do 
    collection do 
      post "/qualifications/:unregister_emp_id" => "employees#qualifications", as: :qualifications
      post "/family_details/:unregister_emp_id" => "employees#family_details", as: :family_details
      delete "/destroy_qualification/:unregister_emp_id" => "employees#destroy_qualification", as: :remove_qualification
      delete "/destroy_family_detail/:unregister_emp_id" => "employees#destroy_family_detail", as: :remove_family_detail
    end
  end

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
    root 'invoices#index', as: :authenticated_root
  end

  unauthenticated :user do
    devise_scope :user do 
      get "/", to: "devise/sessions#new"
    end
  end
end
