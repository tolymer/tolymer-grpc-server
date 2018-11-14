class Participant < ApplicationRecord
  belongs_to :event

  def to_proto
    Tolymer::V1::Participant.new(id: id, name: name)
  end
end
