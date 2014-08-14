class ContactsController < ApplicationController
  include TokenAuthentication
  
  def create
    
    errors = []
    Phoner::Phone.default_country_code = '1'
    
    contact_params[:contacts].each do |c|
      
      begin
        phone = Phoner::Phone.parse c[:phone_number]
      rescue Exception
        render json: {
          error: "Contact " + c[:name] + " has an invalid phone number: " + c[:phone_number],
          status: 400
        }, status: 400
        return
      end
        
      if phone.to_s.length < 10 then
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
        @current_user.contact_relationships.build(contact_id: contact.id)
      end    
    end
  
    @current_user.save
    @contacts = @current_user.contacts
  end

  private
    def contact_params
      params.permit(contacts: [:phone_number, :name])
    end 
  
end