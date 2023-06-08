Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3001', 'localhost:3000', 'news-crawler-ai.herokuapp.com', 'news-crawler-ai.vercel.app', 'job-generator-application.herokuapp.com', 'job-intro-questions-generator.vercel.app', 'code-assistant-frontend.vercel.app'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end