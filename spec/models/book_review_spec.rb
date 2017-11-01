require 'rails_helper'

RSpec.describe BookReview, type: :model do
  context "relationships" do
    it { should belong_to :book }
  end
end
