require 'twilio-ruby'

class UsersController < ApplicationController
  def login
    # User exists
    if @user = User.where(phone_number: params[:user][:phone_number]).first
      # Clear the user's old token logging them out of any other devices
      @user.token = nil
    else
      @user = User.create(user_params)
    end
    
    # Create new activation code
    @user.generate_access_code()
    @user.save
    
    # Twilio Setup
    account_sid = 'ACa368ee5d51fb013936cd1cac3f6cd403'
    auth_token = 'f55dca0ee814bc21e7d034f8c6585d6c'
    
    # Set up a client to talk to the Twilio REST API
    @twilio_client = Twilio::REST::Client.new account_sid, auth_token
    
    #TODO: Check for valid phone number
    
    # Send access code
    @twilio_client.account.messages.create(
      :from => '+15059337234',
      :to => "+" + @user.phone_number.to_s,
      :body => 'Your Companion access code is ' + @user.access_code.to_s
    )
  end
  
  def access_code
    if @user = User.where(phone_number: params[:user][:phone_number], 
      access_code: params[:user][:access_code]).first
      
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