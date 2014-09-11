require 'twilio-ruby'

class RoutesController < ApplicationController
  include TokenAuthentication
  
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
    
    # Assign contacts to the route
    # Twilio Setup
    account_sid = 'ACa368ee5d51fb013936cd1cac3f6cd403'
    auth_token = 'f55dca0ee814bc21e7d034f8c6585d6c'
    
    # Set up a client to talk to the Twilio REST API
    @twilio_client = Twilio::REST::Client.new account_sid, auth_token 
    
    contact_params[:contacts].each do |contact_param|
      logger.debug(contact_param.to_s)
      contact = User.find(contact_param[:id])
      @route.contacts << contact
      
      if contact.push_token then
        APNS.send_notification(contact.push_token, :alert => @current_user.phone_number + " wants to know, will you make sure "+contact.pronoun("he")+" arrives home safely?", :badge => 1, :sound => 'default')
      else
        @twilio_client.account.messages.create(
          :from => '+15059337234',
          :to => contact.phone_number.to_s,
          :body => @current_user.phone_number + " wants to know, will you make sure "+contact.pronoun("he")+" arrives home safely? You can follow "+contact.pronoun("him")+" here http://companionapp.brandontreb.com/routes/" + @route.slug
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
    
    @route.update(route_params)
    
    if @route.complete then
      # Twilio Setup
      account_sid = 'ACa368ee5d51fb013936cd1cac3f6cd403'
      auth_token = 'f55dca0ee814bc21e7d034f8c6585d6c'
    
      # Set up a client to talk to the Twilio REST API
      @twilio_client = Twilio::REST::Client.new account_sid, auth_token      
      @route.contacts.each do |contact|
        # TODO: Check for push token
        # Send access code
        if contact.push_token then
          APNS.send_notification(contact.push_token, :alert => @current_user.phone_number + " arrived at "+contact.pronoun("his")+" destination safely.", :badge => 1, :sound => 'default')
        else
          @twilio_client.account.messages.create(
            :from => '+15059337234',
            :to => contact.phone_number.to_s,
            :body => @current_user.phone_number + " arrived at "+contact.pronoun("his")+" destination safely."
          )
        end
      end
    end
    
    @route.save
    
  end
  
  def broadcast
    @route = Route.find(params[:route_id])
    if @route == nil then
      render json: {
        error: "That route does not exist",
        status: 400
      }, status: 400
      return
    end
    
    # Twilio Setup
    account_sid = 'ACa368ee5d51fb013936cd1cac3f6cd403'
    auth_token = 'f55dca0ee814bc21e7d034f8c6585d6c'
    
    # Set up a client to talk to the Twilio REST API
    @twilio_client = Twilio::REST::Client.new account_sid, auth_token      
    @route.contacts.each do |contact|
      # TODO: Check for push token
      # Send access code
      if contact.push_token then
        APNS.send_notification(contact.push_token, :alert => @current_user.phone_number + " did not arrive at "+contact.pronoun("his")+" destination safely, check in on "+contact.pronoun("him")+"?", :badge => 1, :sound => 'default')
      else
        @twilio_client.account.messages.create(
          :from => '+15059337234',
          :to => contact.phone_number.to_s,
          :body => @current_user.phone_number + " did not arrive at "+contact.pronoun("his")+" destination safely. You can check on "+contact.pronoun("him")+" here http://companionapp.brandontreb.com/routes/" + @route.slug
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
      :complete)
    end
    
    def contact_params
      params.permit(contacts: [:id])
    end
  
end