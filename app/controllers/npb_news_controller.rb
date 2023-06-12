class NpbNews < ApplicationController
  before_action :find_news, only: [:show]

  def index
    @npb_news = NpbNews.all
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