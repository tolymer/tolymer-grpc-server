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

describe HelloService do
  let(:rpc_service) { Tolymer::Hello::Service }
  let(:rpc_desc) { rpc_service.rpc_descs.values.first }
  let(:message) { Tolymer::GreetRequest.new(id: 1) }
  let(:controller) do
    HelloService.new(
      method_key: :greet,
      service: rpc_service,
      active_call: GrpcTestCall.new,
      message: message,
      rpc_desc: rpc_desc,
    )
  end

  let(:response) { controller.call(:greet) }

  it 'returns an instance of Rpc::GetThingResponse' do
    expect(response).to be_instance_of(Tolymer::GreetResponse)
    expect(response.id).to eq message.id
    expect(response.name).to eq 'hello'
  end
end
