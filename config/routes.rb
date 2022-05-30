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

  resources :posts, only: %i[index create]
  scope module: :posts do
    resource  :editing,   only: %i[update]
    resources :scheduled,  only: %i[create edit update destory]
    resources :drafts,    except: %i[show]
  end

  resources :tags, except: %i[index show], constraints: OnlyAjaxConstraints.new
end