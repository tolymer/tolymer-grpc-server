create_table 'events', force: :cascade do |t|
  t.string 'token',       null: false
  t.text   'description', null: false, default: ''
  t.date   'event_date',  null: false

  t.timestamps
end

add_index 'events', 'token', unique: true, using: :btree
