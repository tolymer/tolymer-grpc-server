FactoryBot.define do
  factory :event do
    description { 'event description' }
    event_date { Date.new(2020, 1, 1) }
  end
end
