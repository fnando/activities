module Activities
  class Dsl
    attr_accessor :trackable
    attr_accessor :reflection_name

    def track(action, options = {})
      options = prepare_options(action, options)
      check_validity!(options)
      on = options.delete(:on)
      trackable.activity_trackers[on] ||= []
      trackable.activity_trackers[on] << options.merge(:action => action, :reflection_name => reflection_name)
    end

    protected
    def prepare_options(action, options = {}) # :nodoc:
      options[:on] ||= action if [:create, :update, :destroy].include?(action)
      options
    end

    def check_validity!(options) # :nodoc:
      raise ArgumentError, "the track method expects :on to be set" unless [:create, :update, :destroy].include?(options[:on])
    end
  end
end
