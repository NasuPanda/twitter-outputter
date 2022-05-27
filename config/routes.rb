Rails.application.routes.draw do
  require 'sidekiq/web'
  # sidekiqのダッシュボード
  mount Sidekiq::Web, at: '/sidekiq'

  root 'welcome#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  delete '/logout' => 'sessions#destroy'

  resources :tags

  # FIXME twitter controller 自体移す
  get '/tweet' => 'twitter#update'
  # FIXME 消す
  get 'welcome/show' => "welcome#show"
end
