require 'rails_helper'

RSpec.describe Publisher, type: :model do
  context "relationships" do
    it { should have_many :books }
  end

  
end
