create_table 'tip_results', force: :cascade do |t|
  t.bigint  'tip_id',         null: false
  t.bigint  'participant_id', null: false
  t.decimal 'score',          null: false, precision: 6, scale: 1

  t.timestamps
end

add_index 'tip_results', ['tip_id', 'participant_id'], unique: true, using: :btree
