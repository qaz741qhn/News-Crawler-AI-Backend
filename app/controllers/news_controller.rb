class NewsController < ApplicationController
  def index
    @news = News.all
    render json: @news
  end

  def show
    @news = News.find(params[:id])
    render json: @news
  end
end
