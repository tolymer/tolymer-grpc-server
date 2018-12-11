require 'rails_helper'

describe GameResult do
  let(:game_result) { FactoryBot.create(:game_result, score: 3.2) }

  it do
    expect(game_result.to_proto.score).to eq 3.2
  end
end
