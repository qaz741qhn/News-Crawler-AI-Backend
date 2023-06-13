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

  news_links.first(5).each do |news_link|
    fetch_individual_npb_news_post(url, news_link, title_css, content_css, image_css, date_css, team)
    puts "NPB Team Name: #{team}"
    puts "===== #{source} 新聞を保存しました！ ====="
  end
end

namespace :fetch_npb_news_posts do
  teams = {
    'buffaloes' => [
      ['https://hochi.news/tag/%E3%82%AA%E3%83%AA%E3%83%83%E3%82%AF%E3%82%B9', 'li.newslist__item a', 'オリックスバファローズのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/buffaloes/', 'div.storycard-feed__content a', 'オリックスバファローズのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/orix/', 'div.l-main__content-primary a', 'オリックスバファローズのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/buffaloes/news/', 'ul.newslist a', 'オリックスバファローズの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/buffaloes/', 'li.cateBaseball a', 'オリックスバファローズのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'hawks' => [
      ['https://hochi.news/tag/%E3%82%BD%E3%83%95%E3%83%88%E3%83%90%E3%83%B3%E3%82%AF', 'li.newslist__item a', 'ソフトバンクホークスのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/hawks/', 'div.storycard-feed__content a', 'ソフトバンクホークスのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/softbank/', 'div.l-main__content-primary a', 'ソフトバンクホークスのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/hawks/news/', 'ul.newslist a', 'ソフトバンクホークスの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/hawks/', 'li.cateBaseball a', 'ソフトバンクホークスのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'marines' => [
      ['https://hochi.news/tag/%E3%83%AD%E3%83%83%E3%83%86', 'li.newslist__item a', '千葉ロッテマリーンズのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/marines/', 'div.storycard-feed__content a', '千葉ロッテマリーンズのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/lotte/', 'div.l-main__content-primary a', '千葉ロッテマリーンズのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/marines/news/', 'ul.newslist a', '千葉ロッテマリーンズの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/marines/', 'li.cateBaseball a', '千葉ロッテマリーンズのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'eagles' => [
      ['https://hochi.news/tag/%E6%A5%BD%E5%A4%A9', 'li.newslist__item a', '楽天イーグルスのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/eagles/', 'div.storycard-feed__content a', '楽天イーグルスのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/rakuten/', 'div.l-main__content-primary a', '楽天イーグルスのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/eagles/news/', 'ul.newslist a', '楽天イーグルスの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/eagles/', 'li.cateBaseball a', '楽天イーグルスのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'fighters' => [
      ['https://hochi.news/tag/%E6%97%A5%E6%9C%AC%E3%83%8F%E3%83%A0', 'li.newslist__item a', '日本ハムファイターズのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/fighters/', 'div.storycard-feed__content a', '日本ハムファイターズのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/nipponham/', 'div.l-main__content-primary a', '日本ハムファイターズのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/fighters/news/', 'ul.newslist a', '日本ハムファイターズの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/fighters/', 'li.cateBaseball a', '日本ハムファイターズのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'lions' => [
      ['https://hochi.news/tag/%E8%A5%BF%E6%AD%A6', 'li.newslist__item a', '埼玉西武ライオンズのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/lions/', 'div.storycard-feed__content a', '埼玉西武ライオンズのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/pacific-league/seibu/', 'div.l-main__content-primary a', '埼玉西武ライオンズのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/lions/news/', 'ul.newslist a', '埼玉西武ライオンズの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/lions/', 'li.cateBaseball a', '埼玉西武ライオンズのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'giants' => [
      ['https://hochi.news/giants/', 'li.newslist__item a', '読売ジャイアンツのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/giants/', 'div.storycard-feed__content a', '読売ジャイアンツのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/central-league/kyojin/', 'div.l-main__content-primary a', '読売ジャイアンツのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/giants/news/', 'ul.newslist a', '読売ジャイアンツの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/giants/', 'li.cateBaseball a', '読売ジャイアンツのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'tigers' => [
      ['https://hochi.news/tag/%E9%98%AA%E7%A5%9E', 'li.newslist__item a', '阪神タイガースのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/tigers/', 'div.storycard-feed__content a', '阪神タイガースのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/central-league/hanshin/', 'div.l-main__content-primary a', '阪神タイガースのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/tigers/news/', 'ul.newslist a', '阪神タイガースの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/tigers/', 'li.cateBaseball a', '阪神タイガースのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'carp' => [
      ['https://hochi.news/tag/%E5%BA%83%E5%B3%B6', 'li.newslist__item a', '広島カープのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/carp/', 'div.storycard-feed__content a', '広島カープのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/central-league/hiroshima/', 'div.l-main__content-primary a', '広島カープのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/carp/news/', 'ul.newslist a', '広島カープの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/carp/', 'li.cateBaseball a', '広島カープのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'dragons' => [
      ['https://hochi.news/tag/%E4%B8%AD%E6%97%A5', 'li.newslist__item a', '中日ドラゴンズのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/dragons/', 'div.storycard-feed__content a', '中日ドラゴンズのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/central-league/chunichi/', 'div.l-main__content-primary a', '中日ドラゴンズのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/dragons/news/', 'ul.newslist a', '中日ドラゴンズの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/dragons/', 'li.cateBaseball a', '中日ドラゴンズのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'swallows' => [
      ['https://hochi.news/tag/%E3%83%A4%E3%82%AF%E3%83%AB%E3%83%88', 'li.newslist__item a', 'ヤクルトスワローズのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/swallows/', 'div.storycard-feed__content a', 'ヤクルトスワローズのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/central-league/yakult/', 'div.l-main__content-primary a', 'ヤクルトスワローズのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/swallows/news/', 'ul.newslist a', 'ヤクルトスワローズの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/swallows/', 'li.cateBaseball a', 'ヤクルトスワローズのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ],
    'baystars' => [
      ['https://hochi.news/tag/%EF%BC%A4%EF%BD%85%EF%BC%AE%EF%BC%A1', 'li.newslist__item a', '横浜DeNAベイスターズのスポーツ報知', 'h1', 'div.preview__detail p', 'div.preview__image img', "meta[itempop='datePublished'] content"],
      ['https://www.sanspo.com/tag/npb/baystars/', 'div.storycard-feed__content a', '横浜DeNAベイスターズのサンスポ', 'h1', 'p.article__text', 'figure.article__image img', 'p[data-component="date-format"]'],
      ['https://full-count.jp/category/npb/central-league/dena/', 'div.l-main__content-primary a', '横浜DeNAベイスターズのフルカウント', 'h1', 'div.c-wp-post p', 'figure.s-entry-header__pic img', "meta[property='article:published_time'] content"],
      ['https://www.nikkansports.com/baseball/professional/team/baystars/news/', 'ul.newslist a', '横浜DeNAベイスターズの日刊スポーツ', 'h1', 'div.article-body p', 'div.article-photo-area img', 'header.article-title time'],
      ['https://www.sponichi.co.jp/baseball/tokusyu/baystars/', 'li.cateBaseball a', '横浜DeNAベイスターズのスポニチ', 'h1', "div[data-component='article-body'] p", 'span.bg img', 'p[data-component="date-format"]']
    ]
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

