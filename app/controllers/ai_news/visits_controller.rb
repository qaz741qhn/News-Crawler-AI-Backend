class VisitsController < ApplicationController
  def create
    # Get the current total count of visits
    total_visits = Visit.sum(:count)

    # Increase the total count by 1 for the new visitor
    total_visits += 1

    # Save the new visit
    @visit = Visit.new(count: 1) # Every new visit has a count of 1
    if @visit.save
      # Send back the new total count of visits
      render json: { count: total_visits }, status: :created
    else
      render json: @visit.errors, status: :unprocessable_entity
    end
  end
end
