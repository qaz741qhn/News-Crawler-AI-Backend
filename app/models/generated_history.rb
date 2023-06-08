class GeneratedHistory < ApplicationRecord
  validates :history_type, :keywords, :content, presence: true
end