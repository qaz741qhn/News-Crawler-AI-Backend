namespace :delete_oldest_news do
  desc "Delete oldest 10 news if total count is over 300"
  task delete_oldest_news: :environment do
    if News.count > 300
      News.order(created_at: :asc).limit(10).destroy_all
      puts "Deleted 10 oldest news"
    else
      puts "Total news count is not over 300"
    end
  end
end
