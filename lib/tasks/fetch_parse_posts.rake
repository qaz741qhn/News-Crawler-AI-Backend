def fetch_and_parse(url)
  unparsed_page = HTTParty.get(url)
  Nokogiri::HTML(unparsed_page.body)
end

def fetch_individual_ai_news_post(url, news_link, title_css, content_css, date_css)
  news_url = news_link['href']&.start_with?("http") ? news_link['href'] : URI.join(url, news_link['href']).to_s
  puts "AI News url: #{news_url}"

  existing_news = News.find_by(source: news_url)
  if existing_news
    puts "AI News already exists, skipping..."
    return
  end

  news_unparsed_page = HTTParty.get(news_url)
  news_parsed_page = Nokogiri::HTML(news_unparsed_page.body)

  title = news_parsed_page.css(title_css).text
  puts "AI News Title: #{title}"
  content = news_parsed_page.css(content_css).text
  puts "AI News Content: #{content}"

  date_element = news_parsed_page.css(date_css).first
  if date_element && date_element['datetime']
    date = DateTime.parse(date_element['datetime'])
  else
    date = date_element ? DateTime.parse(date_element.text) : nil
  end
  puts "AI News Date: #{date}"

  openai_client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])

  response = openai_client.completions(
    engine: "text-davinci-003",
    prompt: "Summarize the following article in English 50 words or less:\n\n#{content}",
    max_tokens: 150
  )

  summary = response.choices.first.text.strip
  puts "AI News Summary: #{summary}"

  News.create(title: title, summary: summary, content: content, source: news_url, date: date) 
end

def fetch_individual_npb_news_post(url, news_link, title_css, content_css, image_css, date_css, team_name)

  href = news_link.attr('href')
  return unless href

  news_url = href.start_with?("http") ? href : URI.join(url, href).to_s
  puts "NPB News url: #{news_url}"
  existing_news = NpbNews.find_by(source: news_url)
  if existing_news
    puts "NPB News already exists, skipping..."
    return
  end

  news_unparsed_page = HTTParty.get(news_url)
  news_parsed_page = Nokogiri::HTML(news_unparsed_page.body)

  title = news_parsed_page.css(title_css).text
  puts "NPB News Title: #{title}"
  content = news_parsed_page.css(content_css).text
  puts "NPB News Content: #{content}"

  image_element = news_parsed_page.css(image_css).first
  image_url = image_element ? image_element['src'] : nil
  puts "NPB News Image URL: #{image_url}"

  date_element = news_parsed_page.css('date_css').first
  date_string = date_element.text.gsub(/（|）|\[|\]/, '').strip if date_element
  date_string = date_element['content'] if date_string.nil? && date_element
  date = parse_date(date_string) if date_string

  puts "NPB News Date: #{date}"

  NpbNews.create(title: title, content: content, source: news_url, image_url: image_url, date: date, team_name: team_name)
end

def parse_date(date_string)
  begin
    return DateTime.strptime(date_string, '%Y年%m月%d日 %H:%M')
  rescue ArgumentError
    begin
      return DateTime.strptime(date_string, '%m月%d日 %H:%M')
    rescue ArgumentError
      begin
        return DateTime.parse(date_string)
      rescue ArgumentError
        return nil
      end
    end
  end
end

# ========================== AI NEWS ==========================

namespace :fetch_ai_news_posts do
  task fetch_aibusiness_posts: :environment do
    url = "https://aibusiness.com/latest-news"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.ListPreview-Title')

    news_links.first(10).each do |news_link|
      fetch_individual_ai_news_post(url, news_link, 'h1.ArticleBase-HeaderTitle', 'div.ArticleBase-BodyContent p', 'p.Contributors-Date')
      puts "===== AI Business Posts saved! ====="
    end
  end

  task fetch_aidaily_posts: :environment do
    url = "https://www.aidaily.co.uk/articles/index.html"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.BlogList-item-title')

    news_links.first(10).each do |news_link|
      fetch_individual_ai_news_post(url, news_link, 'h1.BlogItem-title', 'div.sqs-layout p', 'time.Blog-meta-item--date')
      puts "===== AI Daily Posts saved! ====="
    end
  end

  task fetch_google_ai_blog_posts: :environment do
    url = "https://ai.googleblog.com"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.post-outer-container')

    news_links.first(10).each do |news_link|
      fetch_individual_ai_news_post(url, news_link, 'h1.hero__title', 'div.post-body-container p', 'time.eyebrow')
      puts "===== Google AI Blog Posts saved! ====="
    end
  end

  task fetch_venturebeat_posts: :environment do
    url = "https://venturebeat.com/category/ai/"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('a.ArticleListing__title-link')

    news_links.first(10).each do |news_link|
      fetch_individual_ai_news_post(url, news_link, 'h1.article-title', 'div.article-content p', 'time.the-time')
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
      fetch_individual_ai_news_post(url, news_link, 'h1', 'div#content p', 'span.f-meta-2')
      puts "===== OpenAI Blog Posts saved! ====="
    end
  end  

  task fetch_syncedreview_posts: :environment do
    url = "https://syncedreview.com/category/ai/"
    parsed_page = fetch_and_parse(url)
    news_links = parsed_page.css('h2.entry-title a')

    news_links.first(10).each do |news_link|
      fetch_individual_ai_news_post(url, news_link, 'h1.entry-title', 'div.entry-content p', 'time.entry-date')
      puts "===== Synced Review Posts saved! ====="
    end
  end

  task fetch_all: [:fetch_aibusiness_posts, :fetch_aidaily_posts, :fetch_google_ai_blog_posts, 
    :fetch_venturebeat_posts, :fetch_openai_blog_posts, :fetch_syncedreview_posts] do
    puts "===== All posts fetched! ====="
  end
  
end

# ========================== NPB NEWS ==========================

def fetch_npb_news(team, url, selector, source, title_css, content_css, image_css, date_css)
  parsed_page = fetch_and_parse(url)
  news_links = parsed_page.css(selector)

  news_links.first(8).each do |news_link|
    fetch_individual_npb_news_post(url, news_link, title_css, content_css, image_css, date_css, team)
    puts "NPB Team Name: #{team}"
    puts "===== #{source} 新聞を保存しました！ ====="
  end
end

namespace :fetch_npb_news_posts do
  teams = {
    'orix' => [
      ['https://hochi.news/tag/%E3%82%AA%E3%83%AA%E3%83%83%E3%82%AF%E3%82%B9', 'li.newslist__item a', 'オリックスのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/buffaloes/', 'div.storycard-feed__content a', 'オリックスのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/orix/', 'div.l-main__content-primary a', 'オリックスのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/buffaloes/news/', 'ul.newslist a', 'オリックスの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/buffaloes/', 'li.cateBaseball a', 'オリックスのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'softbank' => [
      ['https://hochi.news/tag/%E3%82%BD%E3%83%95%E3%83%88%E3%83%90%E3%83%B3%E3%82%AF', 'li.newslist__item a', 'ソフトバンクのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/hawks/', 'div.storycard-feed__content a', 'ソフトバンクのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/softbank/', 'div.l-main__content-primary a', 'ソフトバンクのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/hawks/news/', 'ul.newslist a', 'ソフトバンクの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/hawks/', 'li.cateBaseball a', 'ソフトバンクのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'lotte' => [
      ['https://hochi.news/tag/%E3%83%AD%E3%83%83%E3%83%86', 'li.newslist__item a', 'ロッテのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/marines/', 'div.storycard-feed__content a', 'ロッテのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/lotte/', 'div.l-main__content-primary a', 'ロッテのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/marines/news/', 'ul.newslist a', 'ロッテの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/marines/', 'li.cateBaseball a', 'ロッテのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'rakuten' => [
      ['https://hochi.news/tag/%E6%A5%BD%E5%A4%A9', 'li.newslist__item a', '楽天のスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/eagles/', 'div.storycard-feed__content a', '楽天のサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/rakuten/', 'div.l-main__content-primary a', '楽天のフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/eagles/news/', 'ul.newslist a', '楽天の日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/eagles/', 'li.cateBaseball a', '楽天のスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'nipponham' => [
      ['https://hochi.news/tag/%E6%97%A5%E6%9C%AC%E3%83%8F%E3%83%A0', 'li.newslist__item a', '日本ハムのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/fighters/', 'div.storycard-feed__content a', '日本ハムのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/nipponham/', 'div.l-main__content-primary a', '日本ハムのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/fighters/news/', 'ul.newslist a', '日本ハムの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/fighters/', 'li.cateBaseball a', '日本ハムのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'seibu' => [
      ['https://hochi.news/tag/%E8%A5%BF%E6%AD%A6', 'li.newslist__item a', '西武のスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/lions/', 'div.storycard-feed__content a', '西武のサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/seibu/', 'div.l-main__content-primary a', '西武のフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/lions/news/', 'ul.newslist a', '西武の日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/lions/', 'li.cateBaseball a', '西武のスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
  }

  teams.each do |team, news_sources|
    news_sources.each_with_index do |news_source, index|
      task "fetch_#{team}_posts_#{index}": :environment do
        fetch_npb_news(team, *news_source)
        puts "===== #{news_source[2]}の新聞を保存しました! ====="
      end
    end

    task "fetch_all_#{team}_posts": news_sources.each_with_index.map { |_, index| "fetch_#{team}_posts_#{index}".to_sym } do
      puts "===== #{team}の新聞を全て保存しました! ====="
    end
  end
end

