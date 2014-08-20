class Route < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :contacts, :class_name => 'User', :join_table => 'users_routes'
end
