class EventsService < Gruf::Controllers::Base
  bind Tolymer::V1::Events::Service

  def get_event
    event = find_event
    Tolymer::V1::GetEventResponse.new(event: event.to_proto)
  end

  def create_event
  end

  def update_event
  end

  def create_game
  end

  def update_game
  end

  def delete_game
  end

  def create_tip
  end

  def update_tip
  end

  def delete_tip
  end

  private

  def find_event
    Event.find_by(token: request.message.token)
  end
end
