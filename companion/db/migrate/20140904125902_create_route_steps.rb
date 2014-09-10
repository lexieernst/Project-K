class CreateRouteSteps < ActiveRecord::Migration
  def change
    create_table :route_steps do |t|
      t.float :latitude
      t.float :longitude
      t.integer :route_id

      t.timestamps
    end
  end
end
