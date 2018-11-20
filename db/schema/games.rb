create_table 'games', force: :cascade do |t|
  t.bigint  'event_id', null: false

  t.timestamps
end

add_index 'games', 'event_id', using: :btree
