class NewsController < ApplicationController
  before_action :find_news, only: [:show, :translate]

  def index
    @news = News.all
    render json: @news
  end

  def show
    render json: @news
  end

  def translate
    if @news.translation.nil?
      @news.translation = generate_translation
      @news.save
    end
    render json: { translation: @news.translation }
  end

  private

  def find_news
    @news = News.find(params[:id])
  end

  def generate_translation
    prompt = params[:prompt]
    generator = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    response = generator.completions(
      engine: "text-davinci-003",
      prompt: prompt,
      max_tokens: 600
    )
    response.choices.first.text.strip
  end
end
