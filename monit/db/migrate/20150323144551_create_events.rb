class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :event_type
      t.string :unit_type
      t.string :unit_count

      t.timestamps null: false
    end
  end
end
