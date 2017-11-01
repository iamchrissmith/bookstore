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
        expect(search_results.length).to eq 1
        expect(search_results).to include(book_author)
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

    xdescribe "publisher match" do
      let(:publisher) { create(:publisher, name: "Find & Co.")}
      let!(:book_publisher) { create(:book, publisher: publisher ) }
      let!(:reviews_publisher) { create_list(:book_review, 3, book: book_publisher)}

    end

    xdescribe "partial title match" do

      context "when using title only flag" do
      end
    end

    xdescribe "multiple criteria matches" do

      it "book should not be duplicated when it matches multiple criteria"

      context "when using format_type flag" do
      end

      context "when using format_physical flag" do
      end

      context "when using multiple flags" do
      end
    end
  end
end
