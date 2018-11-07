class Event < ApplicationRecord
  before_create :set_token

  def set_token
    self.token ||= SecureRandom.hex(20)
  end
end
