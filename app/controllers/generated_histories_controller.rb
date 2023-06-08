class GeneratedHistoriesController < ApplicationController
  def index
    @generated_histories = GeneratedHistory.all
    render json: @generated_histories
  end

  def show
    @generated_history = GeneratedHistory.find(params[:id])
    render json: @generated_history
  end

  def create
    @generated_history = GeneratedHistory.new(generated_history_params)
    if @generated_history.save
      render json: @generated_history, status: :created
    else
      render json: @generated_history.errors, status: :unprocessable_entity
    end
  end

  private

  def generated_history_params
    params.require(:generated_history).permit(:history_type, :content, keywords: {})
  end
end
