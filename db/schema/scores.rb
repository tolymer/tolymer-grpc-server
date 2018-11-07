create_table 'scores', force: :cascade do |t|
  t.bigint  'game_id',   null: false
  t.bigint  'member_id', null: false
  t.integer 'point',     null: false

  t.timestamps
end

add_index 'scores', ['game_id', 'member_id'], unique: true, using: :btree
