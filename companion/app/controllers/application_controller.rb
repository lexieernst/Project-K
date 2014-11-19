require 'parse-ruby-client'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  
  before_filter :init_parse
    
  private   
  def init_parse
			Parse.init :application_id => "FpjjPFLRKBFBON4R4GD8Ut9ARkoDMQBDtURAtKT1",
	           :api_key        => "yVvnM1f9CKJCd3fn4QtwbXJvyEBBvPO318RXiUDP",
	           :quiet           => false
  end      
  
end
