class CodeConversionController < ApplicationController

  def detect_available_languages
    detecter
    languages = eval(@response.choices.first.text.strip)
    render json: { detected_language: languages['detected_language'], available_languages: languages['available_languages']  }
  end 

  def convert_code
    converter
    render json: { converted_code: @response.choices.first.text.strip }
  end

  private

  def detecter
    source_code = params[:source_code]
    detecter = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    @response = detecter.completions(
      engine: "text-davinci-003",
      prompt: "What other programming languages can the following code be converted to? \n#{source_code}\nList the original code's language, and every possible target language in a Ruby hash, there is no limit! For example: {'detected_language' => 'Ruby', 'available_languages' => ['Python', 'Java', 'C++', ...]}",
      max_tokens: 700
    )
  end

  def converter
    target_language = params[:target_language]
    source_code = params[:source_code]

    converter = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    @response = converter.completions(
      engine: "text-davinci-003",
      prompt: "Convert the following code to #{target_language} code:\n#{source_code}",
      max_tokens: 700
    )
  end
end
