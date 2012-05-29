#require "#{RAILS_ROOT}/config/environment.rb"
#require "#{Rails.root}/config/environment.rb"
#require File.expand_path('../application', __FILE__)

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :output, "/home/duke/Desktop/cron_log.log"


every 1.minute do
	#runner "Status.remove_casual", :environment => :development
	
	command system("rvm use 1.9.2@rails3.0.9") && rake "workshop:remove_casuals"#, :environment => :development
end 

