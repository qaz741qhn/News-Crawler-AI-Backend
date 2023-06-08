class RequestsController < ApplicationController
  def create
    generate_response
    render json: { generated_code: @response.choices.first.text.strip }
  end

  private

  def generate_response
    operation = params[:operation]
    language = params[:language] # 從前端獲取語言參數
    generator = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    # 將語言參數加入提示中
    @response = generator.completions(
      engine: "text-davinci-003",
      prompt: "Please provide a sample code snippet demonstrating #{operation} in #{language}.",
      max_tokens: 1000
    )
  end
end
