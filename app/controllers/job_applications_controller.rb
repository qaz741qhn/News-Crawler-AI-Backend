class JobApplicationsController < ApplicationController
  before_action :generate_response, only: [:generate_interview_question, :generate_content]

  def generate_content
    render json: { generated_content: @response.choices.first.text.strip }
  end

  def generate_interview_question
    render json: { generated_interview_questions: @response.choices.first.text.strip }
  end

  def index
    render json: { status: "You are in /job_applications" }
  end

  # POST /job_applications or /job_applications.json
  def create
    @job_application = JobApplication.new(job_application_params)
  
    if @job_application.save
      render json: @job_application, status: :created
    else
      render json: @job_application.errors, status: :unprocessable_entity
    end
  end

  private

    def job_application_params
      params.require(:job_application).permit(:education, :experience, :interested_role, :company_info, :abilities, :professional_values_interests, :soft_skills)
    end

    def generate_response
      prompt = params[:prompt]
      generator = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
      @response = generator.completions(
        engine: "text-davinci-003",
        prompt: prompt,
        max_tokens: 1000
      )
    end
end
