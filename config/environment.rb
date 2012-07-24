# -*- encoding : utf-8 -*-
# Load the rails application

require File.expand_path('../application', __FILE__)
require "#{::Rails.root.to_s}/app/overrides/date"
# Initialize the rails application
Tuni::Application.initialize!

#WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Précédente'
#WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Suivante'
