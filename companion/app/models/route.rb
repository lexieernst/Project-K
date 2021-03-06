class Route < ActiveRecord::Base
  include Sluggable
  # def initialize(route)
  #   @route = route
  # end
  belongs_to :user
  has_and_belongs_to_many :contacts, :class_name => 'User', :join_table => 'users_routes'
  has_many :route_steps
end
