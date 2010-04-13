class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end

class Project < ActiveRecord::Base
  belongs_to :user
  has_many :milestones
  has_many :tasks
end

class Milestone < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end

class User < ActiveRecord::Base
  has_many :milestones
  has_many :tasks
  has_many :projects
end
