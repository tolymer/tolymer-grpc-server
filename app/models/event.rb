class Event < ApplicationRecord
  before_create :set_token

  def set_token
    self.token ||= SecureRandom.hex(20)
  end

  def to_proto
    Tolymer::V1::Event.new(
      token: token,
      title: title,
      description: description,
      date: date.to_s,
      participants: [],
      games: [],
    )
  end
end
