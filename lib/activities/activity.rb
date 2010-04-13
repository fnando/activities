class Activity < ::ActiveRecord::Base
  belongs_to :tracker, :polymorphic => true
  belongs_to :trackable, :polymorphic => true
  serialize :data, Hash
end
