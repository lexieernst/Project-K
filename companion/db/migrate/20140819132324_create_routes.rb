class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.integer :user_id
      t.float :latitude_start
      t.float :longitude_start
      t.float :latitude_end
      t.float :longitude_end
      t.datetime :arrival_date
      t.integer :travel_time
      t.boolean :complete, default: false
      t.timestamps
    end
  end
end
