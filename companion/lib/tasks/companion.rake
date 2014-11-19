namespace :companion do
  
  task send_marketing_messages: :environment do
  	routes = Route.where("sent_marketing_message = ? and updated_at < ?",false,(DateTime.now - 15.seconds))
  	routes.each do |route|
  		route.contacts.each do|contact|
  		
  			if contact.push_token == nil then
  			  begin
		  			# Send marketing messages
		  			account_sid = 'AC276b39d77e43bc54720734cb5bf01c36'
		    		auth_token = 'b77f29432e31a5bd8993e342432ed8c0'
				    @twilio_client = Twilio::REST::Client.new account_sid, auth_token 
				    @twilio_client.account.messages.create(
		          :from => '+12486483597',
		          :to => contact.phone_number.to_s,
		          :body => "Thanks for using Companion! Unlock all the features by downloading the app here: http://bit.ly/1thCObe"
		        )  		
		        
		       rescue Exception
		       
		       end
	      end
  		end
  		# Update the route
  		route.sent_marketing_message = true
  		route.save
  	end
  end
  
  task reset_push_tokens: :environment do
		users = User.where.not(updated_at: (Date.today-7)..(Date.today+1))
		users.each do |user|
			user.push_token = nil
			user.save
		end
  end
  
  task end_routes: :environment do
		routes = Route.where(complete:false)
		routes.each do |route|
			# Expire route after 10 mins
			expire_date = route.created_at + route.travel_time.to_i.seconds + 1200.seconds
			should_complete = expire_date < Time.now
			if should_complete == true then
				route.complete = true
				route.save
			end
		end
  end

end
