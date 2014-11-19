class AddParseObjectIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :parse_object_id, :string
  end
end
