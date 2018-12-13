class EventsService < Gruf::Controllers::Base
  bind Tolymer::V1::Events::Service

  def get_event
    event = find_event
    event.to_proto
  end

  def create_event
    event = Event.create_with_participants!(
      description: message.description,
      participants: message.participants,
    )

    event.to_proto
  rescue ActiveRecord::RecordInvalid, Event::InvalidParticipantsNumbers => err
    fail!(:bad_request, :invalid_parameters, err.message)
  end

  def update_event
    update_mask = fetch_update_mask
    event = find_event

    if update_mask.paths.include?('description')
      event.description = message.description || ''
    end

    event.save!
    event.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, :invalid_parameters, err.message)
  end

  def update_participants
    event = find_event
    event.update_participants!(
      renaming_participants: message.renaming_participants,
      adding_names: message.adding_names,
      deleting_ids: message.deleting_ids,
    )
    Google::Protobuf::Empty.new
  rescue ActiveRecord::RecordNotFound
    fail!(:not_found, :participant_not_found, 'Participant not found')
  rescue ActiveRecord::RecordInvalid, Event::InvalidParticipantsNumbers => err
    fail!(:bad_request, :invalid_parameters, err.message)
  rescue ActiveRecord::RecordNotDestroyed => err
    fail!(:failed_precondition, :invalid_condition, err.message)
  end

  def create_game
    event = find_event
    game = Game.create_with_results!(event_id: event.id, results: message.results)
    game.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, :invalid_parameters, err.message)
  end

  def update_game
    event = find_event
    game = event.games.find(message.game_id)
    update_mask = fetch_update_mask

    if update_mask.paths.include?('results') && message.results.present?
      game.replace_results!(message.results)
    end

    game.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, :invalid_parameters, err.message)
  end

  def delete_game
    event = find_event
    game = event.games.find(message.game_id)
    game.destroy!
    Google::Protobuf::Empty.new
  end

  def post_tip
    event = find_event
    tip = Tip.create_or_replace!(event_id: event.id, results: message.results)
    tip.to_proto
  rescue ActiveRecord::RecordInvalid => err
    fail!(:bad_request, :invalid_parameters, err.message)
  end

  def delete_tip
    tip = find_event.tip
    unless tip
      fail!(:not_found, :tip_not_found, 'Tip does not exist')
    end
    tip.destroy!
    Google::Protobuf::Empty.new
  end

  private

  def message
    request.message
  end

  def find_event
    Event.find_by!(token: message.event_token)
  rescue ActiveRecord::RecordNotFound
    fail!(:not_found, :event_not_found, 'Event not found')
  end

  def fetch_update_mask
    update_mask = message.update_mask

    if update_mask.nil? || update_mask.paths.blank?
      fail!(:bad_request, :invalid_parameters, 'update_mask is required.')
    end

    update_mask
  end
end
