create_table 'game_results', force: :cascade do |t|
  t.bigint  'game_id',        null: false
  t.bigint  'participant_id', null: false
  t.integer 'rank',           null: false
  t.decimal 'score',          null: false, precision: 6, scale: 1

  t.timestamps
end

add_index 'game_results', ['game_id', 'participant_id'], unique: true, using: :btree
