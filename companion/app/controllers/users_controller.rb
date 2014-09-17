require 'twilio-ruby'

class UsersController < ApplicationController
  include TokenAuthentication
  
  def push_token
    
    begin
      push_token = user_params[:push_token]
    rescue Exception
      render json: {
        error: "No push token",
        status: 400
      }, status: 400
      return
    end
    
    @current_user.push_token = push_token
    @current_user.save
    @user = @current_user
  end
  
  def update
    @current_user.update(user_params)
    @current_user.save
    
    # Parses Danny's iPhone to Danny
    if user_params[:name] and user_params[:name].length > 0 then
      name = user_params[:name].split("'") # Split on regular
      name = name[0].split("’") # Split on fancy     	
      
      @current_user.name = name[0]
      @current_user.save
    end
    
    @user = @current_user
  end
  
  private
    def user_params
      params.require(:user).permit(:phone_number, :access_code, :push_token, :gender, :name)
    end  
  
end