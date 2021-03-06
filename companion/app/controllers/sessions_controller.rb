require 'twilio-ruby'

class SessionsController < ApplicationController
  
  def login
    
    errors = []
    Phoner::Phone.default_country_code = '1'
    
    pre = user_params[:phone_number]
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
        error: "Invalid phone number: " + user_params[:phone_number],
        status: 400
      }, status: 400
      return
    end
    
    if phone.to_s.length < 12 then
      render json: {
        error: "Invalid phone number: " + user_params[:phone_number],
        status: 400
      }, status: 400
      return
    end 
    
    logger.debug("phone "  + phone.to_s)
    
    # User exists
    if @user = User.where(phone_number: phone.to_s).first
      # Clear the user's old token logging them out of any other devices
      @user.token = nil
    else
      @user = User.create(phone_number: phone.to_s)
    end
    
    # Create new activation code
    @user.generate_access_code()
    @user.save
    
    # Twilio Setup
    account_sid = 'AC276b39d77e43bc54720734cb5bf01c36'
    auth_token = 'b77f29432e31a5bd8993e342432ed8c0'
    
    # Set up a client to talk to the Twilio REST API
    @twilio_client = Twilio::REST::Client.new account_sid, auth_token
    
    #TODO: Check for valid phone number
    
    # Send access code
    @twilio_client.account.messages.create(
      :from => '+12486483597',
      :to => @user.phone_number.to_s,
      :body => 'Your Companion access code is ' + @user.access_code.to_s
    )
  end
  
  def access_code
    
    errors = []
    Phoner::Phone.default_country_code = '1'    
    
    pre = user_params[:phone_number]
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
        error: "Invalid phone number: " + user_params[:phone_number],
        status: 400
      }, status: 400
      return
    end
    
    if phone.to_s.length < 12 then
      render json: {
        error: "Invalid phone number: " + user_params[:phone_number],
        status: 400
      }, status: 400
      return
    end 
    
    
    if @user = User.where(phone_number: phone.to_s, 
      access_code: user_params[:access_code]).first
      
      # Sucess, generate a login token
      @user.generate_token()
      
      # Clear the access code
      @user.access_code = nil      
      @user.save()
      
    else
      render json: {
        error: "Invalid access code.",
        status: 400
      }, status: 400
    end
  end
  
  private
    def user_params
      params.require(:user).permit(:phone_number, :access_code)
    end 
  
end