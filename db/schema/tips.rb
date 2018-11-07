create_table 'tips', force: :cascade do |t|
  t.bigint  'event_id',  null: false
  t.bigint  'member_id', null: false
  t.integer 'point',     null: false

  t.timestamps
end

add_index 'tips', ['event_id', 'member_id'], unique: true, using: :btree
