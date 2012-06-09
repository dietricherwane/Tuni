# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120606134422) do

  create_table "casual_types", :force => true do |t|
    t.string   "type_name"
    t.integer  "prime"
    t.integer  "hourly_rate"
    t.integer  "months_number"
    t.integer  "max_months_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delay_before_return"
  end

  create_table "casuals", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.date     "birthdate"
    t.string   "identifier"
    t.integer  "months_done"
    t.boolean  "expired"
    t.boolean  "retired_from_ticking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "city_id"
    t.integer  "casual_type_id"
    t.integer  "migration_date_id"
    t.integer  "workshop_id"
    t.integer  "team_id"
    t.string   "phone_number"
    t.integer  "line_id"
    t.integer  "previous_team"
    t.integer  "removal_week"
  end

  create_table "cities", :force => true do |t|
    t.string   "city_name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "company_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.integer  "week_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations_lines", :id => false, :force => true do |t|
    t.integer "configuration_id"
    t.integer "line_id"
  end

  create_table "directions", :force => true do |t|
    t.string   "direction_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extra_hours", :force => true do |t|
    t.integer  "week_number"
    t.date     "bonus_day"
    t.boolean  "authorized"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "team_id"
  end

  create_table "friday_tickings", :force => true do |t|
    t.string   "time_description"
    t.integer  "number_of_hours"
    t.integer  "line_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticking_id"
  end

  create_table "holidays", :force => true do |t|
    t.integer  "week_number"
    t.date     "holiday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "lines", :force => true do |t|
    t.string   "line_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "section_id"
    t.integer  "max_number_of_casuals"
    t.integer  "max_number_of_operators"
  end

  create_table "migration_dates", :force => true do |t|
    t.date     "entrance_date"
    t.date     "exit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "casual_id"
  end

  create_table "monday_tickings", :force => true do |t|
    t.string   "time_description"
    t.integer  "number_of_hours"
    t.integer  "line_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticking_id"
  end

  create_table "rolling_fridays", :force => true do |t|
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_description"
    t.integer  "number_of_hours"
  end

  create_table "rolling_mondays", :force => true do |t|
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_description"
    t.integer  "number_of_hours"
  end

  create_table "rolling_saturdays", :force => true do |t|
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_description"
    t.integer  "number_of_hours"
  end

  create_table "rolling_sundays", :force => true do |t|
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_description"
    t.integer  "number_of_hours"
  end

  create_table "rolling_thursdays", :force => true do |t|
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_description"
    t.integer  "number_of_hours"
  end

  create_table "rolling_tuesdays", :force => true do |t|
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_description"
    t.integer  "number_of_hours"
  end

  create_table "rolling_types", :force => true do |t|
    t.string   "type_name"
    t.string   "description"
    t.integer  "number_of_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled"
  end

  create_table "rolling_wednesdays", :force => true do |t|
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_description"
    t.integer  "number_of_hours"
  end

  create_table "saturday_tickings", :force => true do |t|
    t.string   "time_description"
    t.integer  "number_of_hours"
    t.integer  "line_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticking_id"
  end

  create_table "sections", :force => true do |t|
    t.string   "section_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workshop_id"
  end

  create_table "statuses", :force => true do |t|
    t.string   "status_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sunday_tickings", :force => true do |t|
    t.string   "time_description"
    t.integer  "number_of_hours"
    t.integer  "line_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticking_id"
  end

  create_table "teams", :force => true do |t|
    t.string   "team_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workshop_id"
    t.integer  "max_number_of_casuals"
    t.boolean  "disabled"
    t.boolean  "daily"
    t.integer  "number_of_operators"
  end

  create_table "thursday_tickings", :force => true do |t|
    t.string   "time_description"
    t.integer  "number_of_hours"
    t.integer  "line_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticking_id"
  end

  create_table "tickings", :force => true do |t|
    t.integer  "week_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "casual_id"
  end

  create_table "tuesday_tickings", :force => true do |t|
    t.string   "time_description"
    t.integer  "number_of_hours"
    t.integer  "line_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticking_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone_number"
    t.string   "mobile_number"
    t.integer  "status_number"
    t.integer  "status_id"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "wednesday_tickings", :force => true do |t|
    t.string   "time_description"
    t.integer  "number_of_hours"
    t.integer  "line_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticking_id"
  end

  create_table "workshops", :force => true do |t|
    t.string   "workshop_name"
    t.integer  "direction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_number_of_casuals"
  end

end
