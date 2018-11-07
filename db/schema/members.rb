create_table 'members', force: :cascade do |t|
  t.bigint 'event_id', null: false
  t.string 'name',     null: false

  t.timestamps
end

add_index 'members', 'event_id', using: :btree
