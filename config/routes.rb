Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :todos, only: [ :index, :create, :edit, :update, :destroy ] do
    member do
      patch :toggle
    end
  end

  root "todos#index"
end
