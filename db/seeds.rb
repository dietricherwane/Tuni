# -*- encoding : utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
	Status.create([{ :status_name => 'Administrateur' }, { :status_name => 'Chef de direction' }, { :status_name => "Chef d'atelier" }, {:status_name => "Chef d'équipe"}])
	
	Company.create([{:company_name => "RMO"}, {:company_name => "ECO-CI"}])
	
	City.create([{:city_name => "Yopougon", :short_name => "YOP"}, {:city_name => "Zikisso", :short_name => "ZIK"}])
	
	CasualType.create([{:type_name => "Cariste", :prime => 633, :hourly_rate => 570, :months_number => 6, :max_months_number => 24, :delay_before_return => 3}, {:type_name => "Normal", :prime => 633, :hourly_rate => 473, :months_number => 3, :max_months_number => 24, :delay_before_return => 3}])
	
	Direction.create([{ :direction_name => 'Food' }, { :direction_name => 'HPC' }, { :direction_name => 'Planning' }, { :direction_name => 'Qualité' }, {:direction_name => "SAPROCSY"}])
	
#testing purpose only

	Direction.find_by_direction_name("Food").workshops.create([{ :workshop_name => 'F1' }, { :workshop_name => 'F2' }, { :workshop_name => 'F3' }])
	Direction.find_by_direction_name("HPC").workshops.create([{ :workshop_name => 'HPC1' }, { :workshop_name => 'HPC2' }])
	Direction.find_by_direction_name("Planning").workshops.create([{ :workshop_name => 'PL1' }, { :workshop_name => 'PL2' }, { :workshop_name => 'PL3' }])
	#Direction.find_by_direction_name("Qualité").workshops.create([{ :workshop_name => 'Q1' }, { :workshop_name => 'Q2' }, { :workshop_name => 'F3' }])
	Direction.find_by_direction_name("SAPROCSY").workshops.create([{ :workshop_name => 'SAP1' }, { :workshop_name => 'SAP2' }, { :workshop_name => 'SAP3' }])
	
	Workshop.find_by_workshop_name('F1').teams.create([{ :team_name => 'F1T1' }, { :team_name => 'F1T2' }])
	Workshop.find_by_workshop_name('F2').teams.create([{ :team_name => 'F2T1' }, { :team_name => 'F2T2' }])
	Workshop.find_by_workshop_name('HPC1').teams.create([{ :team_name => 'HPC1T1' }, { :team_name => 'HPC1T2' }])
	Workshop.find_by_workshop_name('HPC2').teams.create([{ :team_name => 'HPC2T1' }, { :team_name => 'HPC2T2' }])
	Workshop.find_by_workshop_name('PL1').teams.create([{ :team_name => 'PL1T1' }, { :team_name => 'PL1T2' }])
	Workshop.find_by_workshop_name('PL2').teams.create([{ :team_name => 'PL2T1' }, { :team_name => 'PL2T2' }])
	Workshop.find_by_workshop_name('PL3').teams.create([{ :team_name => 'PL3T1' }, { :team_name => 'PL3T2' }])
	Workshop.find_by_workshop_name('SAP1').teams.create([{ :team_name => 'SAP1T1' }, { :team_name => 'SAP1T2' }])
	Workshop.find_by_workshop_name('SAP2').teams.create([{ :team_name => 'SAP2T1' }, { :team_name => 'SAP2T2' }])
	Workshop.find_by_workshop_name('SAP3').teams.create([{ :team_name => 'SAP3T1' }, { :team_name => 'SAP3T2' }])
	#User.create(:email => "dietricherwane@live.fr", :password => "dukenukem", :password_confirmation => "dukenukem", :firstname => "Diet", :lastname => "Damon", :status_id => 2)
	
#testing purpose only
