require 'rails_helper'

RSpec.describe Book, type: :model do
  context "relationships" do
    it { should have_many :book_reviews }
    it { should have_many :book_format_types }
    it { should have_many :book_formats }
    it { should belong_to :publisher }
    it { should belong_to :author }
  end

  context "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:publisher_id) }
    it { should validate_presence_of(:author_id) }
  end

  describe "#book_format_types" do
    let(:book) { create(:book) }
    let(:book_format_type) { create(:book_format_type) }
    let!(:book_format) { create(:book_format, book: book, book_format_type: book_format_type) }

    it 'retuns ["Default format"] for book' do 
      expect(book.book_format_types).to be_a ActiveRecord::Associations::CollectionProxy
      expect(book.book_format_types.length).to eq 1
      expect(book.book_format_types[0]).to eq book_format_type
    end
  end

  describe "#author_name" do
    let(:author) { create(:author, first_name: "CFName", last_name: "CLNAME") }
    let!(:book) { create(:book, author: author) }

    it 'returns author name for the book' do
      expect(book.author_name).to be_a String
      expect(book.author_name).to eq "#{author.last_name}, #{author.first_name}"
    end
  end

  describe "#average_rating" do
    let(:book) { create(:book) }
    let!(:reviews) { create_list(:book_review, 3, book: book)}

    it "should return the mean of the reviews for the book (1 decimal accuracy)" do
      average = ((reviews[0].rating + reviews[1].rating + reviews[2].rating) / 3).round(1)
      expect(book.average_rating).to be_an Float
      expect(book.average_rating).to eq average
    end
  end

  describe "#search" do
    let!(:book_no_find) { create(:book) }
    let!(:reviews_no_find) { create_list(:book_review, 3, book: book_no_find)}

    describe "last name match" do
      let(:author) { create(:author, last_name:"Finderson") }
      let!(:book_author) { create(:book, author: author ) }
      let!(:reviews_author) { create_list(:book_review, 3, book: book_author)}
      
      it "should return the book with the last name" do
        search_results = Book.search(author.last_name)
        expect(search_results).to be_a ActiveRecord::Relation
        expect(search_results).to include(book_author)
        expect(search_results.length).to eq 1
        expect(search_results).not_to include(book_no_find)
      end

      it "should return the book with the last name - case insensitive" do
        search_results = Book.search("FINDERSON")
        expect(search_results).to be_a ActiveRecord::Relation
        expect(search_results.length).to eq 1
        expect(search_results).to include(book_author)
        expect(search_results).not_to include(book_no_find)
      end
    end

    describe "publisher match" do
      let(:publisher) { create(:publisher, name: "Find & Co.")}
      let!(:book_publisher) { create(:book, publisher: publisher ) }
      let!(:reviews_publisher) { create_list(:book_review, 3, book: book_publisher)}

      it "should return the book with the publisher" do
        search_results = Book.search(publisher.name)
        expect(search_results).to be_a ActiveRecord::Relation
        expect(search_results.length).to eq 1
        expect(search_results).to include(book_publisher)
        expect(search_results).not_to include(book_no_find)
      end
    end

    describe "partial title match" do
      let!(:book_title) { create(:book, title: "Find Yourself Title") }
      let!(:reviews_title) { create_list(:book_review, 3, book: book_title)}

      it "should return the book with the matching title" do
        search_results = Book.search("Find")
        expect(search_results).to be_a ActiveRecord::Relation
        expect(search_results.length).to eq 1
        expect(search_results).to include(book_title)
        expect(search_results).not_to include(book_no_find)
      end

      context "when using title only flag" do
        let(:author) { create(:author, last_name:"Find") }
        let!(:book_author) { create(:book, author: author ) }
        let!(:reviews_author) { create_list(:book_review, 3, book: book_author)}

        it "should return the book with the matching title" do
          search_results = Book.search("Find", {title_only: true})
          expect(search_results).to be_a ActiveRecord::Relation
          expect(search_results.length).to eq 1
          expect(search_results).to include(book_title)
          expect(search_results).not_to include(book_no_find)
          expect(search_results).not_to include(book_author)
        end
      end
    end

    describe "multiple criteria matches" do
      let(:author) { create(:author, last_name:"Find") }
      let!(:book_multiple) { create(:book, title: "Find Yourself Title", author: author ) }
      let!(:reviews_multiple) { create_list(:book_review, 3, book: book_multiple)}
      let!(:book_multiple_2) { create(:book, title: "Find Another" ) }
      let!(:reviews_multiple_2) { create_list(:book_review, 3, book: book_multiple_2, rating: 0)}

      it "returns multiple books not duplicated and ordered correctly" do 
        search_results = Book.search("Find")
        expect(search_results).to be_a ActiveRecord::Relation
        expect(search_results.length).to eq 2
        expect(search_results[0]).to eq book_multiple
        expect(search_results[1]).to eq book_multiple_2
        expect(search_results).not_to include(book_no_find)
      end

      context "when using format_type flag" do
        let(:book_type_1) { create(:book_format_type) }
        let(:book_type_2) { create(:book_format_type) }
        let!(:book_format) { create(:book_format, book: book_multiple, book_format_type: book_type_1)}
        let!(:book_format_no_find) { create(:book_format, book: book_no_find, book_format_type: book_type_2)}

        it "returns books that only match the format" do 
          search_results = Book.search("Find", {book_format_type_id: book_type_1.id})
          expect(search_results).to be_a ActiveRecord::Relation
          expect(search_results.length).to eq 1
          expect(search_results).to include(book_multiple)
          expect(search_results).not_to include(book_no_find)
        end
      end

      context "when using format_physical flag" do
      end

      context "when using multiple flags" do
      end
    end
  end
end
