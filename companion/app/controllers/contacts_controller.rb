class ContactsController < ApplicationController
  include TokenAuthentication
  
  def index
    @contacts = @current_user.contacts
  end
  
  def create
    
    errors = []
    Phoner::Phone.default_country_code = '1'
    
    contacts_array = []
    
    contact_params[:contacts].each do |c|
      
      pre = c[:phone_number]
      if pre.at(0) == " " then
        pre = pre.from(1)
      end
    
      if pre.length == 11 and pre.at(0) == "1" then
        pre = pre.from(1)
      end
      
      begin
        phone = Phoner::Phone.parse pre
      rescue Exception
        render json: {
          error: "Contact " + c[:name] + " has an invalid phone number: " + c[:phone_number],
          status: 400
        }, status: 400
        return
      end
        
      if phone.to_s.length < 12 then
        render json: {
          error: "Contact " + c[:name] + " has an invalid phone number: " + c[:phone_number],
          status: 400
        }, status: 400
        return
      end  
        
      logger.debug("phone " + phone.to_s)
  
      contact = User.where(phone_number: phone.to_s).first
  
      if contact == nil then
        contact = User.create(name: c[:name], phone_number: phone.to_s)
      end
  
      if !@current_user.has_contact?(contact) then
        @current_user.contact_relationships.build(contact_id: contact.id, name: c[:name])
      end    
      
      contacts_array << contact
      
    end
  
    @current_user.save
    @contacts = contacts_array
  end

  private
    def contact_params
      params.permit(contacts: [:phone_number, :name])
    end 
  
end