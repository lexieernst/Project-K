class User < ActiveRecord::Base
  include Tokenable
  has_many :contact_relationships
  has_many :contacts, :through => :contact_relationships
  
  def has_contact?(other_user)
    contact_relationships.find_by(contact_id: other_user.id) != nil
  end
  
end

