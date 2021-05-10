FactoryBot.define do
  factory :oecd_representative_request do
    user
    message { Faker::Lorem.sentences(3) }
  end
end
