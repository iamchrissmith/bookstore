class Search
  def initialize(books, query, options)
    @books = books
    @query = query
    @options = options
  end

  def run
    
    execute_search(@books).group(:id).order("rating DESC")
  end


  private 
    attr_reader :query, :options

    def setup_book_format_query(books)
      books = books.joins(:book_format_types)

      if options[:book_format_physical] != nil
        books = books.where("book_format_types.physical = ? ", options[:book_format_physical])
      end
  
      if options[:book_format_type_id]
        books = books.where("book_format_types.id = ? ", options[:book_format_type_id])
      end

      books
    end

    def execute_search(books)
      if options[:book_format_type_id] || options[:book_format_physical] != nil
        books = setup_book_format_query(books)
      end

      if options[:title_only]
        books = books.where("lower(title) LIKE ?", "%#{query.downcase}%")
      else   
        books = books.joins(:author, :publisher)
             .where("lower(authors.last_name) = :query OR lower(publishers.name) = :query OR lower(title) LIKE :fuzzy", 
                   {query: query.downcase, fuzzy: "%#{query.downcase}%"})
      end
      
      books
    end
end