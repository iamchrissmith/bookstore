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
    books = Book.joins(:book_reviews)
                .select("books.*", "avg(book_reviews.rating) AS rating")
                

    if options[:book_format_physical]
      books = books.joins(:book_format_types)
                   .where("book_format_types.physical = ? ", options[:book_format_physical])
    end

    if options[:book_format_type_id]
      books = books.joins(:book_format_types)
                   .where("book_format_types.id = ? ", options[:book_format_type_id])
    end

    if options[:title_only]
      books = books.where("lower(title) LIKE ?", "%#{query.downcase}%")
    else   
      books = books.joins(:author, :publisher)
                    .where("lower(authors.last_name) = :query OR lower(publishers.name) = :query OR lower(title) LIKE :fuzzy", 
                          {query: query.downcase, fuzzy: "%#{query.downcase}%"})
    end

    books.group(:id).order("rating DESC")
  end
end
