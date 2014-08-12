class AddActivationCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_code, :string
  end
end
