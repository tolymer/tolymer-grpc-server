class Tip < ApplicationRecord
  belongs_to :event
  has_many :results, class_name: 'TipResult', dependent: :destroy

  def self.create_or_replace!(event_id:, results:)
    validate_results!(results)

    transaction do
      tip = find_or_create_by!(event_id: event_id)
      tip.results.destroy_all
      results.each do |result|
        tip.results.create!(participant_id: result.participant_id, score: result.score)
      end
      tip
    end
  end

  def self.validate_results!(results)
    # TODO
    # scoreの合計が0になることを検証
    # participant_idが正しいイベント参加者かどうか検証
  end

  def to_proto
    Tolymer::V1::Tip.new(results: results.map(&:to_proto))
  end
end
