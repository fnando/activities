module Activities
  module ActiveRecord
    module ClassMethods
      # Add a new activity trigger.
      #
      #   class User < ActiveRecord::Base
      #     has_many :tasks
      #
      #     activities_for :tasks do
      #       track :create
      #       track :update
      #       track :destroy
      #     end
      #   end
      #
      # The above statement will create activities when
      # a <tt>Thing</tt> instance is created, updated or removed.
      #
      # By default, the activity tracker stores all
      # attributes. But you can specify which attributes you want to
      # save. Just overwrite the method <tt>to_activity</tt> on your
      # trackable model.
      #
      #   class Task < ActiveRecord::Base
      #     belongs_to :project
      #
      #     def to_activity
      #       { :project_name => project.name, :task_name => name }
      #     end
      #   end
      #
      # To track custom actions, you need to specify other options.
      # Imagine you want to track when a task is marked as completed.
      # You can add an activity to this action.
      #
      #   class User < ActiveRecord::Base
      #     has_many :tasks
      #
      #     activities_for :tasks do
      #        track :completed, :on => :update, :if => proc {|task| task.status_changed? && task.status == "completed" }
      #     end
      #   end
      #
      # You can also track when an attribute changes:
      #
      #   class User < ActiveRecord::Base
      #     has_many :projects
      #
      #     activities_for :projects do
      #       track :renamed, :on => :update, :if => :name_changed?
      #     end
      #   end
      #
      # There's also an <tt>:unless</tt> option. REMEMBER: you can't use the <tt>:unless</tt> and <tt>:if</tt>
      # options at the same time.
      #
      def activities_for(reflection_name, &block)
        reflection = self.reflections[reflection_name]
        tracker_class = self

        raise ArgumentError, "#{reflection_name.inspect} is not an existing association" unless reflection
        raise ArgumentError, "no block given" unless block_given?

        tracker_class.class_eval do
          has_many :activities, :as => :tracker
        end

        model_class = reflection.class_name.constantize

        model_class.class_eval do
          unless self.respond_to?(:activity_trackers)
            class << self
              attr_accessor :activity_trackers
            end

            has_many :activities, :as => :trackable

            self.activity_trackers = {}

            after_create   :process_activities_on_create
            before_save    :process_activities_on_update
            before_destroy :process_activities_on_destroy
          end
        end

        dsl = Activities::Dsl.new
        dsl.trackable = model_class
        dsl.reflection_name = reflection.primary_key_name.gsub(/_id$/, "")
        dsl.instance_eval(&block)
      end
    end
  end
end
