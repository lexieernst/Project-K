module TokenAuthentication
  extend ActiveSupport::Concern
  
  included do
    before_filter :restrict_access, :except => :slug
  end
  
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      @current_user = User.where(token: token).first
      @current_user != nil
    end
  end
    
end