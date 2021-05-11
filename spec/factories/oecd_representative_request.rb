FactoryBot.define do
  factory :oecd_representative_request do
    user
    message { Faker::Lorem.sentence }
  end
end
