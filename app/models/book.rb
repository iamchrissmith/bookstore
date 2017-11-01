class Book < ApplicationRecord
  belongs_to :publisher
  belongs_to :author

  has_many :book_formats
  has_many :book_format_types, through: :book_formats

  has_many :book_reviews

  validates :title, presence: true
  validates :publisher_id, presence: true
  validates :author_id, presence: true
end
