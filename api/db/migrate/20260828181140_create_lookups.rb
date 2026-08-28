class CreateLookups < ActiveRecord::Migration[8.1]
  def change
    create_table :lookups do |t|
      t.string :mac, null: false
      t.string :vendor_name

      t.timestamps
    end

    add_index :lookups, :mac, unique: true
  end
end
