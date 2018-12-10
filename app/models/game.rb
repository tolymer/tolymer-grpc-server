class Game < ApplicationRecord
  belongs_to :event
  has_many :results, class_name: 'GameResult', dependent: :destroy

  def self.create_with_results!(event_id:, results:)
    validate_results!(results)
    participant_by_rank = calc_rank(results)

    transaction do
      game = create!(event_id: event_id)
      results.each do |result|
        game.results.create!(
          participant_id: result.participant_id,
          score: result.score,
          rank: participant_by_rank[result.participant_id],
        )
      end
      game
    end
  end

  def self.validate_results!(results)
    # TODO
    # scoreの合計が0になることを検証
    # participant_idが正しいイベント参加者かどうか検証
  end

  def self.calc_rank(results)
    participant_by_rank = {}
    results.sort_by(&:score).reverse.each.with_index(1) do |r, rank|
      participant_by_rank[r.participant_id] = rank
    end
    participant_by_rank
  end

  def replace_results!(results)
    self.class.validate_results!(results)
    participant_by_rank = self.class.calc_rank(results)

    transaction do
      self.results.destroy_all
      results.each do |result|
        self.results.create!(
          participant_id: result.participant_id,
          score: result.score,
          rank: participant_by_rank[result.participant_id],
        )
      end
    end
  end

  def to_proto
    Tolymer::V1::Game.new(id: id, results: results.map(&:to_proto))
  end
end
