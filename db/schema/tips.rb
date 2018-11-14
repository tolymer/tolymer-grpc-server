create_table 'tips', force: :cascade do |t|
  t.bigint  'event_id',       null: false
  t.bigint  'participant_id', null: false
  t.decimal 'point',          null: false, precision: 6, scale: 1

  t.timestamps
end

add_index 'tips', ['event_id', 'participant_id'], unique: true, using: :btree
