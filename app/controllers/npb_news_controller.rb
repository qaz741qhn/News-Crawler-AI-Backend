class NpbNewsController < ApplicationController
  before_action :find_news, only: [:show]

  def index
    if params[:team_name]
      @npb_news = NpbNews.where(team_name: params[:team_name]).order(created_at: :desc)
    else
      @npb_news = NpbNews.all.order(created_at: :desc)
    end
    render json: @npb_news
  end

  def show
    render json: @npb_news
  end

  private

  def find_news
    @npb_news = NpbNews.find(params[:id])
  end
end