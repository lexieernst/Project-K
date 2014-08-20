class AddCurrentLocationToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :latitude_current, :float
    add_column :routes, :longitude_current, :float
  end
end
