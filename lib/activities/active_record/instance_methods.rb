module Activities
  module ActiveRecord
    module InstanceMethods
      def to_activity # :nodoc:
        attributes
      end

      private
      def process_activities(step)
        [self.class.activity_trackers[step]].flatten.compact.each do |options|
          next unless process_activity?(options)

          ::Activity.create!({
            :tracker => self.send(options[:reflection_name]),
            :trackable => self,
            :action => options[:action].to_s,
            :data => to_activity.symbolize_keys
          })
        end
      end

      def process_activity?(options)
        if options[:if]
          check_against = true
          callback = options[:if]
        elsif options[:unless]
          check_against = false
          callback = options[:unless]
        else
          return true
        end

        if callback.respond_to?(:call)
          result = callback[self]
        elsif callback.kind_of?(Symbol)
          result = send(callback)
        end

        !!result == check_against
      end

      def process_activities_on_create
        process_activities(:create)
      end

      def process_activities_on_update
        process_activities(:update) unless new_record?
      end

      def process_activities_on_destroy
        process_activities(:destroy)
      end
    end
  end
end
