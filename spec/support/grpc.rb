class GrpcTestCall
  attr_reader :metadata

  def initialize(metadata = nil)
    @metadata = metadata
  end

  def output_metadata
    @output_metadata ||= {}
  end
end
