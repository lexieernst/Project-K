module TokenAuthentication
  extend ActiveSupport::Concern
  
  included do
    before_filter :restrict_access
  end
  
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      #ApiKey.exists?(access_token: token)
      User.exists?(token: token)
    end
  end
    
end