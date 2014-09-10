# app/models/concerns/tokenable.rb
module Sluggable
  extend ActiveSupport::Concern

  included do
    before_create :generate_slug
  end
  
  def generate_slug
    self.slug = loop do
      random_slug = SecureRandom.urlsafe_base64(nil, false)
      break random_slug unless self.class.exists?(slug: random_slug)
    end
  end
end