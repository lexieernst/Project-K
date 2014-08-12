# app/models/concerns/tokenable.rb
module Tokenable
  extend ActiveSupport::Concern

  # included do
  #   before_create :generate_token
  # end
  
  def generate_access_code
    code = (0...6).map { (48 + rand(10)).chr }.join
    self.access_code = code
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(token: random_token)
    end
  end
end