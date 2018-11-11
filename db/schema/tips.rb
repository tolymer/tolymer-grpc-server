create_table 'tips', force: :cascade do |t|
  t.bigint  'event_id',       null: false
  t.bigint  'participant_id', null: false
  t.integer 'point',          null: false

  t.timestamps
end

add_index 'tips', ['event_id', 'participant_id'], unique: true, using: :btree
