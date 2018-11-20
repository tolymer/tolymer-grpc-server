class Tip < ApplicationRecord
  belongs_to :event
  has_many :results, class_name: 'TipResult', dependent: :destroy

  def self.create_with_results!(event_id:, results:)
    validate_results!(results)

    transaction do
      tip = create!(event_id: event_id)
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

  def replace_results!(results)
    self.class.validate_results!(results)

    transaction do
      self.results.destroy_all
      results.each do |result|
        self.results.create!(participant_id: result.participant_id, score: result.score)
      end
    end
  end

  def to_proto
    Tolymer::V1::Tip.new(
      id: id,
      created_at: Google::Protobuf::Timestamp.new(seconds: created_at.to_i),
      results: results.map(&:to_proto),
    )
  end
end
