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
    let!(:p1) { FactoryBot.create(:participant, event_id: event.id) }
    let!(:p2) { FactoryBot.create(:participant, event_id: event.id) }
    let!(:p3) { FactoryBot.create(:participant, event_id: event.id) }
    let!(:p4) { FactoryBot.create(:participant, event_id: event.id) }
    let!(:game) do
      Game.create_with_results!(event_id: event.id, results: [
        Tolymer::V1::GameResult.new(participant_id: p1.id, score: -10),
        Tolymer::V1::GameResult.new(participant_id: p2.id, score: 20),
        Tolymer::V1::GameResult.new(participant_id: p3.id, score: -50),
        Tolymer::V1::GameResult.new(participant_id: p4.id, score: 40),
      ])
    end
    let!(:tip) do
      Tip.create_or_replace!(event_id: event.id, results: [
        Tolymer::V1::TipResult.new(participant_id: p1.id, score: 10),
        Tolymer::V1::TipResult.new(participant_id: p2.id, score: -20),
        Tolymer::V1::TipResult.new(participant_id: p3.id, score: 50),
        Tolymer::V1::TipResult.new(participant_id: p4.id, score: -40),
      ])
    end
    let(:request_message) { Tolymer::V1::GetEventRequest.new(event_token: token) }

    it 'returns a Event' do
      expect(response).to be_a Tolymer::V1::Event
      expect(response.description).to eq event.description
      expect(response.event_date).to eq ProtobufType.date_to_proto(event.event_date)
      expect(response.participants).to match_array [
        Tolymer::V1::Participant.new(id: p1.id, name: p1.name),
        Tolymer::V1::Participant.new(id: p2.id, name: p2.name),
        Tolymer::V1::Participant.new(id: p3.id, name: p3.name),
        Tolymer::V1::Participant.new(id: p4.id, name: p4.name),
      ]
      expect(response.games[0].id).to eq game.id
      expect(response.games[0].results).to match_array [
        Tolymer::V1::GameResult.new(participant_id: p1.id, score: -10, rank: 3),
        Tolymer::V1::GameResult.new(participant_id: p2.id, score: 20, rank: 2),
        Tolymer::V1::GameResult.new(participant_id: p3.id, score: -50, rank: 4),
        Tolymer::V1::GameResult.new(participant_id: p4.id, score: 40, rank: 1),
      ]
      expect(response.tip.results).to match_array [
        Tolymer::V1::TipResult.new(participant_id: p1.id, score: 10),
        Tolymer::V1::TipResult.new(participant_id: p2.id, score: -20),
        Tolymer::V1::TipResult.new(participant_id: p3.id, score: 50),
        Tolymer::V1::TipResult.new(participant_id: p4.id, score: -40),
      ]
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
        description: 'test description',
        participants: ['a', 'b', 'c', 'd'],
        event_date: { year: 2020, month: 6, day: 1 },
      )
    end

    it 'creates a event' do
      expect(response).to be_a Tolymer::V1::Event
      event = Event.first
      expect(response.token).to eq event.token
      expect(response.description).to eq event.description
      expect(response.event_date).to eq ProtobufType.date_to_proto(event.event_date)
      expect(response.participants.size).to eq 4
      expect(response.participants).to eq event.participants.map(&:to_proto)
      expect(response.games).to eq []
      expect(response.tip).to eq nil
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
        description: 'bar',
        event_date: { year: 2020, month: 6, day: 1 },
        update_mask: Google::Protobuf::FieldMask.new(paths: ['description', 'event_date']),
      )
    end

    it 'updates the event' do
      expect(response).to be_a Tolymer::V1::Event
      event.reload
      expect(event.description).to eq 'bar'
      expect(event.event_date).to eq Date.new(2020, 6, 1)
    end

    context 'without update_mask' do
      let(:request_message) do
        Tolymer::V1::UpdateEventRequest.new(
          event_token: event.token,
          description: 'new description',
        )
      end

      it 'raises GRPC::BadRequest' do
        expect { response }.to raise_error GRPC::InvalidArgument
      end
    end
  end

  describe '#update_participants' do
    let(:rpc_name) { :update_participants }
    let(:event) { FactoryBot.create(:event) }
    let!(:p1) { FactoryBot.create(:participant, event_id: event.id, name: 'p1') }
    let!(:p2) { FactoryBot.create(:participant, event_id: event.id, name: 'p2') }
    let!(:p3) { FactoryBot.create(:participant, event_id: event.id, name: 'p3') }
    let!(:p4) { FactoryBot.create(:participant, event_id: event.id, name: 'p4') }
    let(:request_message) do
      Tolymer::V1::UpdateParticipantsRequest.new(
        event_token: event.token,
        renaming_participants: [
          Tolymer::V1::Participant.new(id: p1.id, name: p1.name),
          Tolymer::V1::Participant.new(id: p2.id, name: 'renamed p2'),
        ],
        adding_names: ['new 1'],
        deleting_ids: [p3.id],
      )
    end

    it 'update participants' do
      expect(response).to be_a Google::Protobuf::Empty
      expect(Participant.count).to eq 4
      expect(Participant.find(p1.id).name).to eq 'p1'
      expect(Participant.find(p2.id).name).to eq 'renamed p2'
      expect(Participant.find_by(id: p3.id)).to eq nil
      expect(Participant.find(p4.id).name).to eq 'p4'
      expect(Participant.where(name: 'new 1')).to be_exist
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

  describe '#post_tip' do
    let(:rpc_name) { :post_tip }
    let(:event) { FactoryBot.create(:event) }
    let(:p1) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p2) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p3) { FactoryBot.create(:participant, event_id: event.id) }
    let(:p4) { FactoryBot.create(:participant, event_id: event.id) }
    let(:request_message) do
      Tolymer::V1::PostTipRequest.new(
        event_token: event.token,
        results: [
          Tolymer::V1::TipResult.new(participant_id: p1.id, score: -10),
          Tolymer::V1::TipResult.new(participant_id: p2.id, score: 20),
          Tolymer::V1::TipResult.new(participant_id: p3.id, score: -50),
          Tolymer::V1::TipResult.new(participant_id: p4.id, score: 40),
        ],
      )
    end

    context 'with tip does not exist' do
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

    context 'when tip exist' do
      before do
        results = [
          Tolymer::V1::TipResult.new(participant_id: p1.id, score: 10),
          Tolymer::V1::TipResult.new(participant_id: p2.id, score: -20),
          Tolymer::V1::TipResult.new(participant_id: p3.id, score: 50),
          Tolymer::V1::TipResult.new(participant_id: p4.id, score: -40),
        ]
        Tip.create_or_replace!(event_id: event.id, results: results)
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
  end

  describe '#delete_tip' do
    let(:rpc_name) { :delete_tip }
    let(:tip) { FactoryBot.create(:tip) }
    let(:request_message) do
      Tolymer::V1::DeleteTipRequest.new(event_token: tip.event.token)
    end

    it 'deletes the tip' do
      expect(response).to be_a Google::Protobuf::Empty
      expect(Tip.count).to eq 0
    end
  end
end
