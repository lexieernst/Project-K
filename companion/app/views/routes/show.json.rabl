object @route

attributes :id, :complete, :slug, :latitude_end, :longitude_end, :latitude_start, :longitude_start, :arrival_text, :time_distance_text

child :route_steps, :object_root => false do
  attributes :id, :latitude, :longitude, :created_at
end

child :user, :object_root => false do
  attributes :id, :name, :phone_number
end