create_table 'tips', force: :cascade do |t|
  t.bigint  'event_id', null: false

  t.timestamps
end

add_index 'tips', 'event_id', unique: true, using: :btree
