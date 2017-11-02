class Book < ApplicationRecord
  belongs_to :publisher
  belongs_to :author

  has_many :book_formats
  has_many :book_format_types, through: :book_formats

  has_many :book_reviews

  validates :title, presence: true
  validates :publisher_id, presence: true
  validates :author_id, presence: true

  def author_name
    "#{author.last_name}, #{author.first_name}"
  end

  def average_rating
    book_reviews.average(:rating).to_i.round(1)
  end

  def self.search(query, options = {})
    books = setup_book_search_query

    Search.new(books, query, options).run
  end

  private

    def self.setup_book_search_query
      joins(:book_reviews)
      .select("books.*", "avg(book_reviews.rating) AS rating")
    end
end
