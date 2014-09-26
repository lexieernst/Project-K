class AddRouteInfoToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :arrival_text, :string
    add_column :routes, :time_distance_text, :string
  end
end
