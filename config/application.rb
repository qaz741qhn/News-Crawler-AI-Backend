require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AiNews
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.openai_client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    config.api_only = true
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:3001', 'localhost:3000', 'news-crawler-ai.herokuapp.com'
        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :patch, :options, :head],
          :credentials => false
      end
    end   
  end
end
