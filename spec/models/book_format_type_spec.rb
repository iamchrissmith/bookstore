require 'rails_helper'

RSpec.describe BookFormatType, type: :model do
  context "relationships" do
    it { should have_many :book_formats }
    it { should have_many :books }
  end
end
