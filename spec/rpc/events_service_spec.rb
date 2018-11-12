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
end
