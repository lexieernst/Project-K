namespace :companion do
  
  task reset_push_tokens: :environment do
		users = User.where.not(updated_at: (Date.today-1)..(Date.today+1))
		users.each do |user|
			user.push_token = nil
			user.save
		end
  end

end
