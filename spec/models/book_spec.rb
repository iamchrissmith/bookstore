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
end
