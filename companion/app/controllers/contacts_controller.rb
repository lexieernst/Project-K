class ContactsController < ApplicationController
  include TokenAuthentication
  
  def create
    logger.debug(contact_params.to_s)
  end
  
  private
    def contact_params
      params.permit(contacts: [:phone_number, :name])
    end 
  
end