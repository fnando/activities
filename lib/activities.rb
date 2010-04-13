require "active_record"
require "activities/version"
require "activities/helper"
require "activities/active_record"
require "activities/activity"
require "activities/dsl"

module Activities
end

ActiveRecord::Base.class_eval do
  include Activities::ActiveRecord::InstanceMethods
  extend Activities::ActiveRecord::ClassMethods
end
