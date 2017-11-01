require 'rails_helper'

RSpec.describe Author, type: :model do
  context "relationships" do
    it { should have_many :books }
  end

  
end
