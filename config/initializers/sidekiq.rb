Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379' }
end

require 'sidekiq/web'

# NOTE: Sidekiqのwebuiにベーシック認証をかける
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV['BASIC_AUTH_USER'], ENV['BASIC_AUTH_PASSWORD']]
end