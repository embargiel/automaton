Rails.application.routes.draw do
  resources :events, only: [:create, :index]

  root to: "welcome#index"
end
