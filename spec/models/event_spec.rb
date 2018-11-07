require 'rails_helper'

describe Event do
  let(:event) { FactoryBot.create(:event) }
  it { expect(event.token.size).to be 40 }
end
