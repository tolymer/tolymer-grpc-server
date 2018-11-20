class GameResult < ApplicationRecord
  def to_proto
    Tolymer::V1::GameResult.new(
      participant_id: participant_id,
      score: score.to_f,
      rank: rank,
    )
  end
end
