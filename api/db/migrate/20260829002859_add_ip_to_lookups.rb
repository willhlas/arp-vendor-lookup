class AddIpToLookups < ActiveRecord::Migration[8.1]
  def change
    add_column :lookups, :ip, :string
  end
end
