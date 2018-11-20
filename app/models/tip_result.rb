class TipResult < ApplicationRecord
  def to_proto
    Tolymer::V1::TipResult.new(
      participant_id: participant_id,
      score: score.to_f,
    )
  end
end
