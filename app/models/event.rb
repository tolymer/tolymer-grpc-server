class Event < ApplicationRecord
  has_many :participants

  before_create :set_token

  def set_token
    self.token ||= SecureRandom.hex(20)
  end

  def to_proto
    Tolymer::V1::Event.new(
      token: token,
      title: title,
      description: description,
      date: Tolymer::V1::Date.new(year: date.year, month: date.month, day: date.day),
      participants: participants.map(&:to_proto),
      games: [],
      tips: [],
    )
  end
end
