class AddNameToContactRelationship < ActiveRecord::Migration
  def change
    add_column :contact_relationships, :name, :string
  end
end
