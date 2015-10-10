class CreateLists < ActiveRecord::Migration
  def up
    create_table :lists do |t|
      t.string :name, null: false
      t.integer :user_id, null: false
    end
  end

  def down
    drop_table :lists
  end
end