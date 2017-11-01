class BookFormat < ApplicationRecord
  belongs_to :book
  belongs_to :bookformattype
end
