object @route

attributes :id, :complete

child :route_steps, :object_root => false do
  attributes :id, :latitude, :longitude, :created_at
end