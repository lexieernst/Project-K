require 'twilio-ruby'

class RoutesController < ApplicationController
  include TokenAuthentication

  def initialize(routes)
    @all_routes = Route.all
  end
  
  def index
    @all_routes = Route.all
  end

  def create
    # First check to see if the user has an existing - non complete - route
    @route = Route.where(user_id: @current_user.id, complete: false).first
    if @route then
      @route.complete = true
      @route.save
    end
    
    # Assign contacts the the route
    @route = Route.create(route_params)
    @route.user = @current_user
    
    # Set the current location based on start
    @route.latitude_current = @route.latitude_start
    @route.longitude_current = @route.latitude_start
    
    name = @current_user.name
    if name.length == 0 then
      name = @current_user.phone_number
    end
    
    @route.complete = false
    
    # Assign contacts to the route
    # Twilio Setup
    account_sid = 'AC276b39d77e43bc54720734cb5bf01c36'
    auth_token = 'b77f29432e31a5bd8993e342432ed8c0'
    bitly = Bitly.new('brandontreb', 'R_2a413ebd15254a72b500ec2ce83f982d')
    
    # Set up a client to talk to the Twilio REST API
    @twilio_client = Twilio::REST::Client.new account_sid, auth_token 
    
    contact_params[:contacts].each do |contact_param|
      logger.debug(contact_param.to_s)
      contact = User.find(contact_param[:id])
      @route.contacts << contact
      
      contact_name = @route.user.contact_relationships.where(contact_id: contact.id).first.name      
      
      if contact.name then
      	contact_name = contact.name
      end
      
      contact_name = contact_name.split(" ")[0]
      
      if contact.push_token then
      	#parse
        text = "Hey " + contact_name + ", " + name + " has requested that you be " + @current_user.pronoun("his") + " companion."
				channel = "companion" + contact.push_token
				data = {:alert => text, :route_id => @route.id.to_s, :badge => 1 }
				push = Parse::Push.new(data,channel)
				push.type = "ios"
				push.save
      else
        text = "Hey " + contact_name + ", " + name + " has requested that you be " + @current_user.pronoun("his") + " companion. Follow " + @current_user.pronoun("him") + " at " + bitly.shorten("http://livemap.companionapp.io/routes/watch/" + @route.slug).short_url
        @twilio_client.account.messages.create(
          :from => '+12486483597',
          :to => contact.phone_number.to_s,
          :body => text
        )
      end
      
    end
    
    @route.save
    
    # Create the initial route steps
    if route_params[:latitude_start] && 
      route_params[:longitude_start] then
      
      route_step = @route.route_steps.build(
      latitude: route_params[:latitude_start],
      longitude: route_params[:longitude_start])
      
      route_step.save      
    end
    
  end
  
  def update
    @route = Route.find(params[:id])
    if @route == nil then
      render json: {
        error: "That route does not exist",
        status: 400
      }, status: 400
      return
    end
    
    if route_params[:latitude_current] && 
      route_params[:longitude_current] then
      
      route_step = @route.route_steps.build(
      latitude: route_params[:latitude_current],
      longitude: route_params[:longitude_current])
      
      route_step.save
      
    end
    
    if route_params[:complete] == "true" and @route.complete != true then
      name = @current_user.name
      if name.length == 0 then
        name = @current_user.phone_number
      end
      
      # Twilio Setup
      account_sid = 'AC276b39d77e43bc54720734cb5bf01c36'
      auth_token = 'b77f29432e31a5bd8993e342432ed8c0'
    	bitly = Bitly.new('brandontreb', 'R_2a413ebd15254a72b500ec2ce83f982d')
    	
      # Set up a client to talk to the Twilio REST API
      @twilio_client = Twilio::REST::Client.new account_sid, auth_token      
      
      message = name + " has arrived at "+@current_user.pronoun("his")+" destination safely."
      if params[:force] then
      	message = name + " has ended "+@current_user.pronoun("his")+" trip."
      end
      
      @route.contacts.each do |contact|
								        
        if contact.push_token then

          channel = "companion" + contact.push_token
					data = {:alert => message, :route_id => @route.id.to_s, :badge => 1 }
					push = Parse::Push.new(data,channel)
					push.type = "ios"
					push.save

        else
          @twilio_client.account.messages.create(
            :from => '+12486483597',
            :to => contact.phone_number.to_s,
            :body => message
          )
        end
      end
    end    
    
    @route.update(route_params)
    @route.save!
    
  end
  
  def broadcast
  	type = params[:type]
    @route = Route.find(params[:route_id])
    if @route == nil then
      render json: {
        error: "That route does not exist",
        status: 400
      }, status: 400
      return
    end
    
    name = @current_user.name
    if name.length == 0 then
      name = @current_user.phone_number
    end
    
    # Twilio Setup
    account_sid = 'AC276b39d77e43bc54720734cb5bf01c36'
    auth_token = 'b77f29432e31a5bd8993e342432ed8c0'
  	bitly = Bitly.new('brandontreb', 'R_2a413ebd15254a72b500ec2ce83f982d')
  	  
    # Set up a client to talk to the Twilio REST API
    @twilio_client = Twilio::REST::Client.new account_sid, auth_token      
    @route.contacts.each do |contact|
      
      contact_name = @route.user.contact_relationships.where(contact_id: contact.id).first.name      
      
      if contact.name then
      	contact_name = contact.name
      end
      
      contact_name = contact_name.split(" ")[0]

			# Did not arrive
			if type == 'no_arrive' then
				message = name + " did not arrive at "+@current_user.pronoun("his")+" destination safely, check in on "+@current_user.pronoun("him")+"?"      
			elsif type == 'request' then
				message = name + " has requested that you check in on "+@current_user.pronoun("him")+"."      			
			elsif type == 'ok' then
				message = name + " has confirmed "+@current_user.pronoun("he")+" is okay."      			
			end

      
      if contact.push_token then				
        
        channel = "companion" + contact.push_token
				data = {:alert => message, :route_id => @route.id.to_s, :badge => 1 }
				push = Parse::Push.new(data,channel)
				push.type = "ios"
				push.save

      else
	      message = message + " " + bitly.shorten("http://livemap.companionapp.io/routes/watch/" + @route.slug).short_url
	      
        @twilio_client.account.messages.create(
          :from => '+12486483597',
          :to => contact.phone_number.to_s,
          :body => message
        )
      end
    end
  end
  
  def show
    @route = Route.find(params[:id])
  end
  
  def slug
    @route = Route.where(slug: params[:slug]).first
  end
  
  def watching
 		@routes = @current_user.routes_watching.where(complete:false)
 		
 		if params[:route_id] then
 			r = Route.find(params[:route_id])
 			unless @routes.include?(r)
	   		@routes << r
			end
 		end
 		
  end
  
  private
    def route_params
      params.require(:route).permit(
      :latitude_start, 
      :longitude_start, 
      :latitude_end,
      :longitude_end,
      :latitude_current,
      :longitude_current,
      :arrival_date,
      :travel_time,
      :arrival_text,
      :time_distance_text,
      :complete)
    end
    
    def contact_params
      params.permit(contacts: [:id])
    end
  
end