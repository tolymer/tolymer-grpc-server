class Participant < ApplicationRecord
  MAX_NAME_LENGTH = 50

  has_many :game_results
  has_many :tip_results
  belongs_to :event

  validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }

  before_destroy :check_scores_for_destroy, prepend: true

  def to_proto
    Tolymer::V1::Participant.new(id: id, name: name)
  end

  private

  def check_scores_for_destroy
    if game_results.exists? || tip_results.exists?
      throw :abort
    end
  end
end
