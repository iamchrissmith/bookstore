require 'rails_helper'

RSpec.describe Book, type: :model do
  context "relationships" do
    it { should have_many :book_reviews }
    it { should have_many :book_format_types }
    it { should have_many :book_formats }
    it { should belong_to :publisher }
    it { should belong_to :author }
  end
end
