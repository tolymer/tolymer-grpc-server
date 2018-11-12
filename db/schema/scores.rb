create_table 'scores', force: :cascade do |t|
  t.bigint  'game_id',        null: false
  t.bigint  'participant_id', null: false
  t.integer 'point',          null: false

  t.timestamps
end

add_index 'scores', ['game_id', 'participant_id'], unique: true, using: :btree
