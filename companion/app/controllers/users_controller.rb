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
    
    @user = @current_user
    @user.push_token = push_token
    @user.save
    
  end
  
  def update
    @current_user.update(user_params)
    @user = @current_user
  end
  
  private
    def user_params
      params.require(:user).permit(:phone_number, :access_code, :push_token, :gender)
    end  
  
end