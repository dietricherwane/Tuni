namespace :workshop do

	desc "Testing whenever gem"
	task :remove_casuals => :environment do
		Status.create(:status_name => "Whenever")
	end
	
end

