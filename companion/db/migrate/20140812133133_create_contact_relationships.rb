class CreateContactRelationships < ActiveRecord::Migration
  def change
    create_table :contact_relationships do |t|
      t.integer :user_id
      t.integer :contact_id
      t.boolean :favorite

      t.timestamps
    end            
  end
end
