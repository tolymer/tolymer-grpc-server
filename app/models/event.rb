class Event < ApplicationRecord
  class InvalidParticipantsNumbers < StandardError; end

  has_many :participants, dependent: :destroy
  has_many :games, dependent: :destroy
  has_one :tip, dependent: :destroy

  before_create :set_token

  def self.create_with_participants!(description:, participants:)
    participants = participants.reject(&:blank?)

    if participants.size != 4
      raise InvalidParticipantsNumbers
    end

    transaction do
      event = create!(description: description)

      participants.each do |name|
        event.participants.create!(name: name.strip)
      end

      event
    end
  end

  def update_participants!(renaming_participants: [], adding_names: [], deleting_ids: [])
    transaction do
      renaming_participants.each do |participant|
        participants.find(participant.id).update!(name: participant.name)
      end

      adding_names.each do |name|
        participants.create!(name: name)
      end

      deleting_ids.each do |id|
        participants.find(id).destroy!
      end

      if participants.count != 4
        raise InvalidParticipantsNumbers
      end
    end

    participants
  end

  def to_proto
    Tolymer::V1::Event.new(
      token: token,
      description: description,
      participants: participants.order(:id).map(&:to_proto),
      games: games.map(&:to_proto),
      tip: tip&.to_proto,
    )
  end

  private

  def set_token
    self.token ||= SecureRandom.hex(20)
  end
end
