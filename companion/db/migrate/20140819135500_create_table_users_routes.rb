class CreateTableUsersRoutes < ActiveRecord::Migration
  def change
    create_table :users_routes, id: false do |t|
      t.belongs_to :user
      t.belongs_to :route
    end
  end
end
