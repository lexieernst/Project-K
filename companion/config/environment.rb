# Load the Rails application.
require File.expand_path('../application', __FILE__)

APNS.host = 'gateway.push.apple.com' 
#gateway.sandbox.push.apple.com is default

APNS.pem  = './config/apns_prod_cert.pem'
# this is the file you just created

APNS.port = 2195 
# this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.

# APNS.pass = 'tr4v15'

# Initialize the Rails application.
Rails.application.initialize!
