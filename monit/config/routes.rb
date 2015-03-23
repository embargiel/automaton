Rails.application.routes.draw do
  resources :events, only: [:create]

  root to: "welcome#index"
end
