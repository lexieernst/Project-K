class DashboardController < ApplicationController
	def index
		@all_routes = Route.all
	end
end

