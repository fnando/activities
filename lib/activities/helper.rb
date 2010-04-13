module Activities
  module Helper
    def render_activity(activity)
      path = "activities/#{activity.trackable_type.underscore}/#{activity.action}"
      locals = {
        :activity => activity,
        :tracker => activity.tracker,
        :trackable => activity.trackable,
        :data => activity.data
      }
      render :partial => path, :locals => locals
    end
  end
end
