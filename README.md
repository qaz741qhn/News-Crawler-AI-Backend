# NewsCrawlerAI

NewsCrawlerAI is an AI-driven news crawler designed specifically for AI and tech enthusiasts. It can automatically fetch news from multiple top AI and tech websites, and uses the capabilities of OpenAI GPT-4 to generate a summary for each news, allowing users to quickly understand the content of the news. Moreover, its powerful features include deduplication, to avoid storing duplicate news in the database.

## Features

1. Fetch news from multiple AI and tech websites.
2. Generate summaries for each news using OpenAI GPT-3.
3. Deduplicate news based on their URLs.
4. Save news and summaries to a database for later usage.

## Prerequisites

1. Ruby version 2.7.0 or later.
2. Rails version 6.0.0 or later.
3. An OpenAI API key.

## Setup

1. Clone the repository to your local machine.
2. Install the required gems by running `bundle install`.
3. Setup your database by running `rails db:migrate`.
4. Add your OpenAI API key to the `.env` file.

## Usage

To start the crawler, run `rake fetch_all_posts`. The task will start to fetch and summarize news from multiple sources, and save them into the database.

## Contributing

Please feel free to fork this repository and submit pull requests. We appreciate your contribution to the improvement of NewsCrawlerAI.

## License

This project is licensed under the MIT License.
