class User < ActiveRecord::Base
  include Tokenable
  has_many :contact_relationships
  has_many :contacts, :through => :contact_relationships
  has_many :routes
  has_and_belongs_to_many :routes_watching, :class_name => 'Route', :join_table => 'users_routes'
  
  def has_contact?(other_user)
    contact_relationships.find_by(contact_id: other_user.id) != nil
  end
  
  def pronoun(type)
    if type == "he" then
      return self.gender == "male" ? "he" : "she"
    end
    if type == "him" then
      return self.gender == "male" ? "him" : "her"
    end
    
    if type == "his" then
      return self.gender == "male" ? "his" : "her"
    end
  end
  
end

