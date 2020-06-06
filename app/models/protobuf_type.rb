module ProtobufType
  def self.date_to_proto(val)
    return unless val
    Tolymer::V1::Date.new(
      year: val.year,
      month: val.month,
      day: val.day
    )
  end

  def self.proto_to_date(val)
    return unless val
    Date.new(val.year, val.month, val.day)
  end
end
