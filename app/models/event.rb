class Event < ApplicationRecord
  MAX_TITLE_LENGTH = 100

  has_many :participants, dependent: :destroy
  has_many :games, dependent: :destroy
  has_one :tip, dependent: :destroy

  validates :title, presence: true, length: { maximum: MAX_TITLE_LENGTH }
  validates :date, presence: true

  before_create :set_token

  def update_participants!(renamed: [], added: [], deleted: [])
  end

  def to_proto
    Tolymer::V1::Event.new(
      token: token,
      title: title,
      description: description,
      date: Tolymer::V1::Date.new(year: date.year, month: date.month, day: date.day),
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
