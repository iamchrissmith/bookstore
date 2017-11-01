FactoryBot.define do
  factory :book_review do
    book
    rating {rand(1..5)}
  end
end
