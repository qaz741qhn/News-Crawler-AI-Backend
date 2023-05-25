def fetch_and_parse(url)
  unparsed_page = HTTParty.get(url)
  Nokogiri::HTML(unparsed_page.body)
end

def fetch_individual_post(url, news_link, title_css, content_css, date_css)
  news_url = news_link['href'].start_with?("http") ? news_link['href'] : URI.join(url, news_link['href']).to_s
  puts "News url: #{news_url}"

  existing_news = News.find_by(source: news_url)
  if existing_news
    puts "News already exists, skipping..."
    return
  end

  news_unparsed_page = HTTParty.get(news_url)
  news_parsed_page = Nokogiri::HTML(news_unparsed_page.body)

  title = news_parsed_page.css(title_css).text
  puts "Title: #{title}"
  content = news_parsed_page.css(content_css).text
  puts "Content: #{content}"

  date_element = news_parsed_page.css(date_css).first
  if date_element && date_element['datetime']
    date = DateTime.parse(date_element['datetime'])
  else
    date = date_element ? DateTime.parse(date_element.text) : nil
  end
  puts "Date: #{date}"

  openai_client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])

  response = openai_client.completions(
    engine: "text-davinci-003",
    prompt: "Summarize the following article in English 50 words or less:\n\n#{content}",
    max_tokens: 150
  )

  summary = response.choices.first.text.strip
  puts "Summary: #{summary}"

  News.create(title: title, summary: summary, content: content, source: news_url, date: date) 
end

namespace :fetch_posts do
  task fetch_aibusiness_posts: :environment do
    url = "https://aibusiness.com/latest-news"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.ListPreview-Title')

    news_links.first(10).each do |news_link|
      fetch_individual_post(url, news_link, 'h1.ArticleBase-HeaderTitle', 'div.ArticleBase-BodyContent p', 'p.Contributors-Date')
      puts "===== AI Business Posts saved! ====="
    end
  end

  task fetch_aidaily_posts: :environment do
    url = "https://www.aidaily.co.uk/articles/index.html"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.BlogList-item-title')

    news_links.first(10).each do |news_link|
      fetch_individual_post(url, news_link, 'h1.BlogItem-title', 'div.sqs-layout p', 'time.Blog-meta-item--date')
      puts "===== AI Daily Posts saved! ====="
    end
  end

  task fetch_google_ai_blog_posts: :environment do
    url = "https://ai.googleblog.com"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.post-outer-container')

    news_links.first(10).each do |news_link|
      fetch_individual_post(url, news_link, 'h1.hero__title', 'div.post-body-container p', 'time.eyebrow')
      puts "===== Google AI Blog Posts saved! ====="
    end
  end

  task fetch_venturebeat_posts: :environment do
    url = "https://venturebeat.com/category/ai/"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.ArticleListing__title-link')

    news_links.first(10).each do |news_link|
      fetch_individual_post(url, news_link, 'h1.article-title', 'div.article-content p', 'time.the-time')
      puts "===== Venture Beat Posts saved! ====="
    end
  end

  task fetch_openai_blog_posts: :environment do
    url = "https://openai.com/blog"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.ui-link')
  
    news_links = news_links.select do |news_link|
      news_link['href'].include?('/blog')
    end
  
    news_links.first(10).each do |news_link|
      fetch_individual_post(url, news_link, 'h1', 'div#content p', 'span.f-meta-2')
      puts "===== OpenAI Blog Posts saved! ====="
    end
  end  

  task fetch_syncedreview_posts: :environment do
    url = "https://syncedreview.com/category/ai/"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('h2.entry-title a')

    news_links.first(10).each do |news_link|
      fetch_individual_post(url, news_link, 'h1.entry-title', 'div.entry-content p', 'time.entry-date')
      puts "===== Synced Review Posts saved! ====="
    end
  end

  task fetch_all: [:fetch_aibusiness_posts, :fetch_aidaily_posts, :fetch_google_ai_blog_posts, 
    :fetch_venturebeat_posts, :fetch_openai_blog_posts, :fetch_syncedreview_posts] do
    puts "===== All posts fetched! ====="
  end
  
end
