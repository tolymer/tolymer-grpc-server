require 'rails_helper'

describe EventsService do
  let(:rpc_service) { Tolymer::V1::Events::Service }
  let(:rpc_desc) { rpc_service.rpc_descs.values.first }
  let(:response) do
    EventsService.new(
      method_key: rpc_name,
      service: rpc_service,
      active_call: GrpcTestCall.new,
      message: message,
      rpc_desc: rpc_desc,
    ).call(rpc_name)
  end

  describe '#get_event' do
    let(:rpc_name) { :get_event }
    let(:event) { FactoryBot.create(:event) }
    let(:token) { event.token }
    let(:message) { Tolymer::V1::GetEventRequest.new(event_token: token) }

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
    let(:message) do
      Tolymer::V1::CreateEventRequest.new(
        title: 'test title',
        description: 'test description',
        date: Tolymer::V1::Date.new(year: 2018, month: 12, day: 1),
        participants: ['a', 'b', 'c', 'd'],
      )
    end

    it 'creates a Event' do
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
  end
end
