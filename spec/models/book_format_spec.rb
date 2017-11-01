require 'rails_helper'

RSpec.describe BookFormat, type: :model do
  context "relationships" do
    it { should belong_to :book_format_type }
    it { should belong_to :book }
  end
end
