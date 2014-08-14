class ContactRelationship < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id", :class_name => "User"
  belongs_to :contact, :foreign_key => "contact_id", :class_name => "User"
end
