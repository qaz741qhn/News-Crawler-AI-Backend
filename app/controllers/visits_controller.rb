class VisitsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @visit = Visit.new(visit_params)

    if @visit.save
      render json: @visit, status: :created
    else
      render json: @visit.errors, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:count)
  end
end
