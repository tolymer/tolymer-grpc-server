require 'rails_helper'

describe EventsService do
  let(:rpc_service) { Tolymer::V1::Events::Service }
  let(:rpc_desc) { rpc_service.rpc_descs.values.first }
  let(:response) do
    EventsService.new(
      method_key: rpc_name,
      service: rpc_service,
      active_call: GrpcTestCall.new,
      message: request_message,
      rpc_desc: rpc_desc,
    ).call(rpc_name)
  end

  describe '#get_event' do
    let(:rpc_name) { :get_event }
    let(:event) { FactoryBot.create(:event) }
    let(:token) { event.token }
    let(:request_message) { Tolymer::V1::GetEventRequest.new(event_token: token) }

    it 'returns a Event' do
      expect(response).to be_a Tolymer::V1::Event
      expect(response.title).to eq event.title
    end

    context "when specified token does not exist" do
      let(:token) { 'x' }
      it 'raises GRPC::NotFound' do
        expect { response }.to raise_error GRPC::NotFound
      end
    end
  end

  describe '#create_event' do
    let(:rpc_name) { :create_event }
    let(:request_message) do
      Tolymer::V1::CreateEventRequest.new(
        title: 'test title',
        description: 'test description',
        date: Tolymer::V1::Date.new(year: 2018, month: 12, day: 1),
        participants: ['a', 'b', 'c', 'd'],
      )
    end

    it 'creates a event' do
      expect(response).to be_a Tolymer::V1::Event
      event = Event.first
      expect(response.token).to eq event.token
      expect(response.title).to eq event.title
      expect(response.description).to eq event.description
      expect(response.date.year).to eq event.date.year
      expect(response.date.month).to eq event.date.month
      expect(response.date.day).to eq event.date.day
      expect(response.participants.size).to eq 4
      expect(response.participants).to eq event.participants.map(&:to_proto)
      expect(response.games).to eq []
      expect(response.tips).to eq []
    end

    context 'with invalid params' do
      let(:request_message) do
        Tolymer::V1::CreateEventRequest.new
      end

      it 'raises GRPC::InvalidArgument' do
        expect { response }.to raise_error GRPC::InvalidArgument
      end
    end
  end

  describe '#update_event' do
    let(:rpc_name) { :update_event }
    let(:event) { FactoryBot.create(:event) }
    let(:request_message) do
      Tolymer::V1::UpdateEventRequest.new(
        event_token: event.token,
        title: 'foo',
        description: 'bar',
        date: Tolymer::V1::Date.new(year: 2020, month: 12, day: 1),
        update_mask: Google::Protobuf::FieldMask.new(paths: ['title', 'description', 'date']),
      )
    end

    it 'updates the event' do
      expect(response).to be_a Tolymer::V1::Event
      event.reload
      expect(event.title).to eq 'foo'
      expect(event.description).to eq 'bar'
      expect(event.date.to_s).to eq '2020-12-01'
    end

    context 'with title only' do
      let(:request_message) do
        Tolymer::V1::UpdateEventRequest.new(
          event_token: event.token,
          title: 'foo',
          update_mask: Google::Protobuf::FieldMask.new(paths: ['title'])
        )
      end

      it 'updates only title' do
        before_description = event.description
        before_date = event.date
        expect(response).to be_a Tolymer::V1::Event
        event.reload
        expect(event.title).to eq 'foo'
        expect(event.description).to eq before_description
        expect(event.date).to eq before_date
      end
    end

    context 'without update_mask' do
      let(:request_message) do
        Tolymer::V1::UpdateEventRequest.new(
          event_token: event.token,
          title: 'foo',
        )
      end

      it 'raises GRPC::BadRequest' do
        expect { response }.to raise_error GRPC::InvalidArgument
      end
    end
  end

  describe '#create_participant' do
    let(:rpc_name) { :create_participant }
    let(:event) { FactoryBot.create(:event) }
    let(:request_message) do
      Tolymer::V1::CreateParticipantRequest.new(
        event_token: event.token,
        name: 'foo',
      )
    end

    it 'creates a participant' do
      expect(response).to be_a Tolymer::V1::Participant
      participant = event.participants.first
      expect(response.id).to eq participant.id
      expect(response.name).to eq 'foo'
      expect(participant.name).to eq 'foo'
      expect(event.participants.size).to eq 1
    end
  end

  describe '#update_participant' do
    let(:rpc_name) { :update_participant }
    let(:event) { participant.event }
    let(:participant) { FactoryBot.create(:participant) }
    let(:request_message) do
      Tolymer::V1::UpdateParticipantRequest.new(
        event_token: event.token,
        participant_id: participant.id,
        name: 'foo',
        update_mask: Google::Protobuf::FieldMask.new(paths: ['name']),
      )
    end

    it 'updates the participant' do
      expect(response).to be_a Tolymer::V1::Participant
      expect(response.id).to eq participant.id
      expect(response.name).to eq 'foo'
      expect(participant.reload.name).to eq 'foo'
    end
  end

  describe '#delete_participant' do
    let(:rpc_name) { :delete_participant }
    let(:event) { participant.event }
    let(:participant) { FactoryBot.create(:participant) }
    let(:request_message) do
      Tolymer::V1::UpdateParticipantRequest.new(
        event_token: event.token,
        participant_id: participant.id,
      )
    end

    context 'when participant has game results' do
      before do
        participant.game_results.create!(game_id: 1, score: 10, rank: 1)
      end

      it 'raises GRPC::FailedPrecondition' do
        expect { response }.to raise_error GRPC::FailedPrecondition
        expect(event.participants.count).to eq 1
      end
    end

    context 'when participant has tip results' do
      before do
        participant.tip_results.create!(tip_id: 1, score: 10)
      end

      it 'raises GRPC::FailedPrecondition' do
        expect { response }.to raise_error GRPC::FailedPrecondition
        expect(event.participants.count).to eq 1
      end
    end

    context 'when participant does not have results' do
      it 'deletes the participant' do
        expect(response).to be_a Google::Protobuf::Empty
        expect(event.participants.count).to eq 0
      end
    end
  end

  describe '#create_game' do
    let(:rpc_name) { :create_game }
    let(:event) { FactoryBot.create(:event) }
    let(:p1) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p2) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p3) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p4) { FactoryBot.create(:participant, event_id: event.id) }
    let(:request_message) do
      Tolymer::V1::CreateGameRequest.new(
        event_token: event.token,
        results: [
          Tolymer::V1::GameResult.new(participant_id: p1.id, score: -10),
          Tolymer::V1::GameResult.new(participant_id: p2.id, score: 20),
          Tolymer::V1::GameResult.new(participant_id: p3.id, score: -50),
          Tolymer::V1::GameResult.new(participant_id: p4.id, score: 40),
        ],
      )
    end

    it 'creates a game' do
      expect(response).to be_a Tolymer::V1::Game
      expect(response.results).to match_array [
        Tolymer::V1::GameResult.new(participant_id: p1.id, score: -10, rank: 3),
        Tolymer::V1::GameResult.new(participant_id: p2.id, score: 20, rank: 2),
        Tolymer::V1::GameResult.new(participant_id: p3.id, score: -50, rank: 4),
        Tolymer::V1::GameResult.new(participant_id: p4.id, score: 40, rank: 1),
      ]
    end
  end

  describe '#update_game' do
    let(:rpc_name) { :update_game }
    let(:event) { FactoryBot.create(:event) }
    let(:p1) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p2) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p3) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p4) { FactoryBot.create(:participant, event_id: event.id) }
    let(:game) do
      Game.create_with_results!(event_id: event.id, results: [
        Tolymer::V1::GameResult.new(participant_id: p1.id, score: 100),
        Tolymer::V1::GameResult.new(participant_id: p2.id, score: -200),
        Tolymer::V1::GameResult.new(participant_id: p3.id, score: 500),
        Tolymer::V1::GameResult.new(participant_id: p4.id, score: -400),
      ])
    end
    let(:request_message) do
      Tolymer::V1::UpdateGameRequest.new(
        event_token: event.token,
        game_id: game.id,
        results: [
          Tolymer::V1::GameResult.new(participant_id: p1.id, score: -10),
          Tolymer::V1::GameResult.new(participant_id: p2.id, score: 20),
          Tolymer::V1::GameResult.new(participant_id: p3.id, score: -50),
          Tolymer::V1::GameResult.new(participant_id: p4.id, score: 40),
        ],
        update_mask: Google::Protobuf::FieldMask.new(paths: ['results']),
      )
    end

    it 'updates the game' do
      expect(response).to be_a Tolymer::V1::Game
      expect(response.results).to match_array [
        Tolymer::V1::GameResult.new(participant_id: p1.id, score: -10, rank: 3),
        Tolymer::V1::GameResult.new(participant_id: p2.id, score: 20, rank: 2),
        Tolymer::V1::GameResult.new(participant_id: p3.id, score: -50, rank: 4),
        Tolymer::V1::GameResult.new(participant_id: p4.id, score: 40, rank: 1),
      ]
    end
  end

  describe '#delete_game' do
    let(:rpc_name) { :delete_game }
    let(:game) { FactoryBot.create(:game) }
    let(:request_message) do
      Tolymer::V1::DeleteGameRequest.new(
        event_token: game.event.token,
        game_id: game.id,
      )
    end

    it 'deletes the game' do
      expect(response).to be_a Google::Protobuf::Empty
      expect(Game.count).to eq 0
    end
  end

  describe '#create_tip' do
    let(:rpc_name) { :create_tip }
    let(:event) { FactoryBot.create(:event) }
    let(:p1) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p2) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p3) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p4) { FactoryBot.create(:participant, event_id: event.id) }
    let(:request_message) do
      Tolymer::V1::CreateTipRequest.new(
        event_token: event.token,
        results: [
          Tolymer::V1::TipResult.new(participant_id: p1.id, score: -10),
          Tolymer::V1::TipResult.new(participant_id: p2.id, score: 20),
          Tolymer::V1::TipResult.new(participant_id: p3.id, score: -50),
          Tolymer::V1::TipResult.new(participant_id: p4.id, score: 40),
        ],
      )
    end

    it 'creates a tip' do
      expect(response).to be_a Tolymer::V1::Tip
      expect(response.results).to match_array [
        Tolymer::V1::TipResult.new(participant_id: p1.id, score: -10),
        Tolymer::V1::TipResult.new(participant_id: p2.id, score: 20),
        Tolymer::V1::TipResult.new(participant_id: p3.id, score: -50),
        Tolymer::V1::TipResult.new(participant_id: p4.id, score: 40),
      ]
    end
  end

  describe '#update_tip' do
    let(:rpc_name) { :update_tip }
    let(:event) { FactoryBot.create(:event) }
    let(:p1) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p2) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p3) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p4) { FactoryBot.create(:participant, event_id: event.id) }
    let(:tip) do
      Tip.create_with_results!(event_id: event.id, results: [
        Tolymer::V1::TipResult.new(participant_id: p1.id, score: 100),
        Tolymer::V1::TipResult.new(participant_id: p2.id, score: -200),
        Tolymer::V1::TipResult.new(participant_id: p3.id, score: 500),
        Tolymer::V1::TipResult.new(participant_id: p4.id, score: -400),
      ])
    end
    let(:request_message) do
      Tolymer::V1::UpdateTipRequest.new(
        event_token: event.token,
        tip_id: tip.id,
        results: [
          Tolymer::V1::TipResult.new(participant_id: p1.id, score: -10),
          Tolymer::V1::TipResult.new(participant_id: p2.id, score: 20),
          Tolymer::V1::TipResult.new(participant_id: p3.id, score: -50),
          Tolymer::V1::TipResult.new(participant_id: p4.id, score: 40),
        ],
        update_mask: Google::Protobuf::FieldMask.new(paths: ['results']),
      )
    end

    it 'updates the tip' do
      expect(response).to be_a Tolymer::V1::Tip
      expect(response.results).to match_array [
        Tolymer::V1::TipResult.new(participant_id: p1.id, score: -10),
        Tolymer::V1::TipResult.new(participant_id: p2.id, score: 20),
        Tolymer::V1::TipResult.new(participant_id: p3.id, score: -50),
        Tolymer::V1::TipResult.new(participant_id: p4.id, score: 40),
      ]
    end
  end

  describe '#delete_tip' do
    let(:rpc_name) { :delete_tip }
    let(:tip) { FactoryBot.create(:tip) }
    let(:request_message) do
      Tolymer::V1::DeleteTipRequest.new(
        event_token: tip.event.token,
        tip_id: tip.id,
      )
    end

    it 'deletes the tip' do
      expect(response).to be_a Google::Protobuf::Empty
      expect(Tip.count).to eq 0
    end
  end
end
