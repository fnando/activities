require "rubygems"
gem "test-unit"
require "test/unit"
require "active_record"
require "mocha"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
load "schema.rb"

require "activities"
require "resources/models"
