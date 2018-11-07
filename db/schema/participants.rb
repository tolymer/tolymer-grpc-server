create_table 'participants', force: :cascade do |t|
  t.bigint 'event_id', null: false
  t.string 'name',     null: false

  t.timestamps
end

add_index 'participants', 'event_id', using: :btree
