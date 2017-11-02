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

    if options[:book_format_type_id] || options[:book_format_physical] != nil
      books = setup_book_format_query(books,options)
    end

    execute_search(books, query, options).group(:id).order("rating DESC")
  end

  private

    def self.setup_book_search_query
      joins(:book_reviews)
      .select("books.*", "avg(book_reviews.rating) AS rating")
    end

    def self.setup_book_format_query(books, options)
      books = books.joins(:book_format_types)

      if options[:book_format_physical] != nil
        books = books.where("book_format_types.physical = ? ", options[:book_format_physical])
      end
  
      if options[:book_format_type_id]
        books = books.where("book_format_types.id = ? ", options[:book_format_type_id])
      end

      books
    end

    def self.execute_search(books, query, options)
      if options[:title_only]
        books.where("lower(title) LIKE ?", "%#{query.downcase}%")
      else   
        books.joins(:author, :publisher)
             .where("lower(authors.last_name) = :query OR lower(publishers.name) = :query OR lower(title) LIKE :fuzzy", 
                   {query: query.downcase, fuzzy: "%#{query.downcase}%"})
      end
    end
end
