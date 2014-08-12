class User < ActiveRecord::Base
  include Tokenable
  has_many :contacts
end
