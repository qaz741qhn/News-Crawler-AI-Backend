class UserTasksController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_user_task, only: %i[show update destroy]

  def index
    @user_tasks = UserTask.all

    render json: @user_tasks
  end

  def show
    render json: @user_task
  end

  def create
    puts "=====Current user is #{current_user.inspect}====="
    if current_user
      @user_task = current_user.user_tasks.new(user_task_params)
    
      if @user_task.save
        render json: @user_task, status: :created, location: @user_task
      else
        render json: { error: @user_task.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "User not logged in" }, status: :unauthorized
    end
  end   

  def update
    if @user_task.update(user_task_params)
      render json: @user_task
    else
      render json: @user_task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user_task.destroy
  end

  private

  def set_user_task
    @user_task = UserTask.find(params[:id])
  end

  def user_task_params
    params.require(:user_task).permit(:title, :detail, :status)
  end
end
