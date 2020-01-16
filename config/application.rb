# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
# require "active_job/railtie"
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LtiLauncher
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      # Don't generate system test files.
      g.system_tests = nil
      # Use UUID for primary keys
      g.orm :active_record, primary_key_type: :uuid
    end

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    config.force_ssl = secrets.force_ssl

    # Setup the host / domain
    config.action_controller.default_url_options = routes.default_url_options = config.default_url_options = {
      host: secrets.domain,
      port: secrets.domain&.split(':')&.second,
      protocol: secrets.force_ssl ? 'https' : 'http'
    }
    config.hosts = [secrets.domain, secrets.domain&.split(':')&.first].uniq
  end
end
