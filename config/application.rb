require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TwitterOutputter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    # タイムゾーン
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    # i18n
    config.i18n.default_locale = :ja
    # ジェネレータ
		config.generators do |g|
			g.test_framework :rspec,
				fixtures: false,
				view_specs: false,
				helper_specs: false,
				routing_specs: false
			end

    # Herokuエラー対策
    config.assets.initialize_on_precompile = false
    # publicディレクトリに置かれたあたゆるアセットは静的ファイルとして扱われる
    config.public_file_server.enabled = true
  end
end
