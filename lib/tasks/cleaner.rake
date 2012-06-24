namespace :teams do

	desc "Remove casuals which doesn't have configuration plan from lines"
	task :remove_casuals_from_lines => :environment do
		Status.create(:status_name => "Whenever")
	end
	
end

