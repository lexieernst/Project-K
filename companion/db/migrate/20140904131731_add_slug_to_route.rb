class AddSlugToRoute < ActiveRecord::Migration
  def change
    add_column :routes, :slug, :string
  end
end
