Rails.application.routes.draw do
  root 'welcome#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  delete '/logout' => 'sessions#destroy'

  # FIXME twitter controller 自体移す
  get '/tweet' => 'twitter#update'
  # FIXME 消す
  get 'welcome/show' => "welcome#show"
end
