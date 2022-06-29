Rails.application.routes.draw do
  require 'sidekiq/web'
  # sidekiqのダッシュボード
  mount Sidekiq::Web, at: '/sidekiq'
  # OAuth認証
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  delete '/logout' => 'sessions#destroy'

  root 'pages/homes#show'
  scope module: :pages do
    resource :home,     only: %i[show]
    resource :setting,  only: %i[show edit update]
  end

  resources :posts, only: %i[destroy]
  scope module: :posts do
    resources :drafts,    only: %i[index create edit update destroy]
    resources :scheduled, only: %i[index create edit update destroy]
    resources :published, only: %i[index create]
  end
  namespace :posts do
    resources :images, only: %i[destroy]
  end

  resources :tags, only: %i[new create edit update destroy], constraints: OnlyAjaxConstraints.new
  scope module: :tags do
    resources :tagged, only: %i[create destroy], constraints: OnlyAjaxConstraints.new
  end
end