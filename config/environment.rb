# -*- encoding : utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Tuni::Application.initialize!

WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Précédente'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Suivante'
