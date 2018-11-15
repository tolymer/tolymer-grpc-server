class EventsService < Gruf::Controllers::Base
  bind Tolymer::V1::Events::Service

  def get_event
    event = find_event
    event.to_proto
  end

  def create_event
    event = Event.create!(
      title: message.title,
      description: message.description,
      date: message.date ? Date.new(message.date.year, message.date.month, message.date.day) : nil,
    )
    message.participants.each do |name|
      event.participants.create!(name: name)
    end

    event.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, err.message)
  end

  def update_event
    update_mask = fetch_update_mask
    event = find_event

    if update_mask.paths.include?('title') && message.title.present?
      event.title = message.title
    end

    if update_mask.paths.include?('description')
      event.description = message.description || ''
    end

    if update_mask.paths.include?('date') && !message.date.nil?
      event.date = Date.new(message.date.year, message.date.month, message.date.day)
    end

    event.save!
    event.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, err.message)
  end

  def create_participant
    event = find_event
    participant = event.participants.create!(name: message.name)
    participant.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, err.message)
  end

  def update_participant
    event = find_event
    participant = event.participants.find(message.participant_id)
    update_mask = fetch_update_mask

    if update_mask.paths.include?('name') && message.name.present?
      participant.name = message.name
    end

    participant.save!
    participant.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, err.message)
  end

  def delete_participant
    event = find_event
    participant = event.participants.find(message.participant_id)
    participant.destroy!
    Google::Protobuf::Empty.new
  rescue ActiveRecord::RecordNotDestroyed => err
    fail!(:failed_precondition, err.message)
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

  def message
    request.message
  end

  def find_event
    Event.find_by!(token: message.event_token)
  rescue ActiveRecord::RecordNotFound => err
    fail!(:not_found, :event_not_found, 'Invalid event token')
  end

  def fetch_update_mask
    update_mask = message.update_mask

    if update_mask.nil? || update_mask.paths.blank?
      fail!(:bad_request, 'update_mask is required.')
    end

    update_mask
  end
end
