require 'rails_helper'

class GrpcTestCall
  attr_reader :metadata

  def initialize(metadata = nil)
    @metadata = metadata
  end

  def output_metadata
    @output_metadata ||= {}
  end
end

describe EventsService do
  let(:event) { FactoryBot.create(:event) }
  let(:rpc_service) { Tolymer::V1::Events::Service }
  let(:rpc_desc) { rpc_service.rpc_descs.values.first }
  let(:message) { Tolymer::V1::GetEventRequest.new(token: event.token) }
  let(:controller) do
    EventsService.new(
      method_key: :get_event,
      service: rpc_service,
      active_call: GrpcTestCall.new,
      message: message,
      rpc_desc: rpc_desc,
    )
  end

  let(:response) { controller.call(:get_event) }

  it do
    expect(response).to be_instance_of(Tolymer::V1::GetEventResponse)
    expect(response.event.title).to eq event.title
  end
end
