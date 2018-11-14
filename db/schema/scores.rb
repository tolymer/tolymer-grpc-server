create_table 'scores', force: :cascade do |t|
  t.bigint  'game_id',        null: false
  t.bigint  'participant_id', null: false
  t.decimal 'point',          null: false, precision: 6, scale: 1

  t.timestamps
end

add_index 'scores', ['game_id', 'participant_id'], unique: true, using: :btree
