class GameResult < ApplicationRecord
  belongs_to :participant
  belongs_to :game

  def to_proto
    Tolymer::V1::GameResult.new(
      participant_id: participant_id,
      score: score.to_f,
      rank: rank,
    )
  end
end
