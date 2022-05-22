Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter,
  Rails.application.credentials.twitter[:client_id],
  Rails.application.credentials.twitter[:client_secret],
  {
    :x_auth_access_type => 'write'
  }
  on_failure do |env|
    SessionsController.action(:failure).call(env)
  end
end