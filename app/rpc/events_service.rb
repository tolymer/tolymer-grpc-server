class EventsService < Gruf::Controllers::Base
  bind Tolymer::V1::Events::Service

  def get_event
    event = find_event
    event.to_proto
  end

  def create_event
    m = request.message
    event = Event.create!(
      title: m.title,
      description: m.description,
      date: Date.new(m.date.year, m.date.month, m.date.day),
    )
    m.participants.each do |name|
      event.participants.create!(name: name)
    end

    event.to_proto
  end

  def update_event
    m = request.message
    event = find_event

    if m.update_mask.nil? || m.update_mask.paths.blank?
      fail!(:bad_request, 'update_mask is required.')
    end

    if m.update_mask.paths.include?('title') && m.title.present?
      event.title = m.title
    end

    if m.update_mask.paths.include?('description')
      event.description = m.description || ''
    end

    if m.update_mask.paths.include?('date') && !m.date.nil?
      event.date = Date.new(m.date.year, m.date.month, m.date.day)
    end

    event.save!
    event.to_proto
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
    Event.find_by!(token: request.message.event_token)
  rescue ActiveRecord::RecordNotFound => err
    fail!(:not_found, :event_not_found, 'Invalid event token')
  end
end
