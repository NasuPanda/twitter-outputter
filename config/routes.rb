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

  scope module: :posts do
    resources :drafts,    except: %i[show]
    resources :scheduled, only: %i[index create edit update destroy]
    resources :published, only: %i[index create]
  end

  resources :tags, except: %i[index show], constraints: OnlyAjaxConstraints.new
  scope module: :tags do
    resources :added, only: %i[create destroy]
  end
end