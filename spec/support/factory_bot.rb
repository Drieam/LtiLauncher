# frozen_string_literal: true

require 'factory_bot_rails'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.lint
    # Make sure to clean the database again
    DatabaseCleaner.clean_with(:truncation)
  end
end
