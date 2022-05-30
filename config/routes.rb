Rails.application.routes.draw do
  require 'sidekiq/web'
  # sidekiqのダッシュボード
  mount Sidekiq::Web, at: '/sidekiq'

  scope module: :pages do
    resource :home,     only: %i[show]
    resource :setting,  only: %i[show edit update]
  end

  root 'pages/homes#show'
  resources :tags, except: %i[index show], constraints: OnlyAjaxConstraints.new
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  delete '/logout' => 'sessions#destroy'
end