Rails.application.routes.draw do
  root 'welcome#index'
  get 'auth/:provider/callback' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  # FIXME twitter controller 自体移す
  get '/tweet' => 'twitter#update'
end
