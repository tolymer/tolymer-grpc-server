FactoryBot.define do
  factory :game_result do
    participant
    game
    rank { 1 }
    score { 50 }
  end
end
