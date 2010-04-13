require "test_helper"

class Activities::ActiveRecordTest < Test::Unit::TestCase
  def setup
    %w[User Task Milestone Project].each do |name|
      Object.send(:remove_const, name) rescue nil
    end
    load "resources/models.rb"

    User.delete_all
    Project.delete_all
    Task.delete_all
    Milestone.delete_all
    Activity.delete_all

    @user = User.create(:login => "johndoe")
  end

  def test_models_should_respond_to_activities_for
    assert User.respond_to?(:activities_for)
  end

  def test_activities_for_expects_an_association
    assert_raise ArgumentError do
      User.activities_for
    end
  end

  def test_activities_for_expects_a_valid_association
    assert_raise ArgumentError do
      User.activities_for :invalid do
        track :create
      end
    end
  end

  def test_activities_for_expects_a_block
    assert_raise ArgumentError do
      User.activities_for :projects
    end
  end

  def test_setup_trackable_class
    User.activities_for(:tasks) do
      track :create
      track :update
      track :destroy
      track :renamed, :on => :update, :if => :name_changed?
    end

    expected = {
      :create => [{:reflection_name => "user", :action => :create}],
      :update => [
        {:reflection_name => "user", :action => :update},
        {:reflection_name => "user", :action => :renamed, :if => :name_changed?}
      ],
      :destroy => [{:reflection_name => "user", :action => :destroy}]
    }
    assert_equal(expected, Task.activity_trackers)
  end

  def test_add_multiple_trackers
    User.activities_for(:tasks) { track :create }
    Project.activities_for(:tasks) { track :create }

    expected = {
      :create => [
        { :reflection_name => "user", :action => :create },
        { :reflection_name => "project", :action => :create }
      ]
    }
    assert_equal(expected, Task.activity_trackers)
  end

  def test_add_multiple_activities
    User.activities_for(:tasks) { track :create }
    Project.activities_for(:tasks) { track :create }

    @project = Project.create(:user => @user)
    @task = @project.tasks.create(:user => @user, :name => "New task")

    assert_equal 1, @user.activities.count(:conditions => {:action => "create"})
    assert_equal 1, @project.activities.count(:conditions => {:action => "create"})
  end

  def test_store_attributes_for_activity
    User.activities_for(:tasks) do
      track :create
    end

    @task = @user.tasks.create(:name => "New task")
    @activity = @user.activities.first

    assert_equal @task.attributes.symbolize_keys, @activity.data
  end

  def test_activity_for_create
    User.activities_for(:tasks) do
      track :create
    end

    @task = @user.tasks.create(:name => "New task")
    @task.update_attribute :name, "Updated task"
    @task.destroy

    assert_equal 1, @user.activities.count(:conditions => {:action => "create"})
    assert_equal 1, @user.activities.count
  end

  def test_activity_for_destroy
    User.activities_for(:tasks) do
      track :destroy
    end

    @task = @user.tasks.create(:name => "New task")
    @task.update_attribute :name, "Updated task"
    @task.destroy

    assert_equal 1, @user.activities.count(:conditions => {:action => "destroy"})
    assert_equal 1, @user.activities.count
  end

  def test_activity_for_update
    User.activities_for(:tasks) do
      track :update
    end

    @task = @user.tasks.create(:name => "New task")
    @task.update_attribute :name, "Updated task"
    @task.destroy

    assert_equal 1, @user.activities.count(:conditions => {:action => "update"})
    assert_equal 1, @user.activities.count
  end

  def test_create_activities_for_all_actions
    User.activities_for(:tasks) do
      track :create
      track :update
      track :destroy
    end

    @task = @user.tasks.create(:name => "New task")
    assert_equal 1, @user.activities.count(:conditions => {:action => "create"})

    @task.update_attribute :name, "Updated task"
    assert_equal 1, @user.activities.count(:conditions => {:action => "update"})

    @task.destroy
    assert_equal 1, @user.activities.count(:conditions => {:action => "destroy"})

    assert_equal 3, @user.activities.count
  end

  def test_create_activity_respecting_the_if_option_using_symbol
    User.activities_for(:projects) do
      track :renamed, :on => :update, :if => :name_changed?
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    @project.update_attribute :name, "Updated project"

    assert_equal 1, @user.activities.count(:conditions => {:action => "renamed"})
    assert_equal 1, @user.activities.count
  end

  def test_dont_create_activity_when_if_evaluation_returns_false_symbol
    User.activities_for(:projects) do
      track :renamed, :on => :update, :if => :name_changed?
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    assert_equal 0, Activity.count

    @project.update_attribute :status, "archived"
    assert_equal 0, Activity.count
  end

  def test_create_activity_respecting_the_if_option_using_block
    User.activities_for(:projects) do
      track :renamed, :on => :update, :if => proc {|r| r.name_changed?}
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    @project.update_attribute :name, "Updated project"

    assert_equal 1, @user.activities.count(:conditions => {:action => "renamed"})
    assert_equal 1, @user.activities.count
  end

  def test_dont_create_activity_when_if_evaluation_returns_false_block
    User.activities_for(:projects) do
      track :renamed, :on => :update, :if => proc {|r| r.name_changed?}
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    assert_equal 0, Activity.count

    @project.update_attribute :status, "archived"
    assert_equal 0, Activity.count
  end

  def test_create_activity_respecting_the_unless_option_using_symbol
    User.activities_for(:projects) do
      track :renamed, :on => :update, :unless => :status_changed?
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    @project.update_attribute :name, "Updated project"
    assert_equal 1, @user.activities.count(:conditions => {:action => "renamed"})
    assert_equal 1, @user.activities.count
  end

  def test_create_activity_respecting_the_unless_option_using_block
    User.activities_for(:projects) do
      track :renamed, :on => :update, :unless => proc {|r| r.status_changed?}
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    @project.update_attribute :name, "Updated project"
    assert_equal 1, @user.activities.count(:conditions => {:action => "renamed"})
    assert_equal 1, @user.activities.count
  end

  def test_dont_create_activity_when_unless_evaluation_returns_false_block
    User.activities_for(:projects) do
      track :renamed, :on => :update, :unless => proc {|r| r.status_changed?}
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    @project.update_attributes :status => "archived", :name => "Updated project"
    assert_equal 0, Activity.count
  end

  def test_dont_create_activity_when_unless_evaluation_returns_false_symbol
    User.activities_for(:projects) do
      track :renamed, :on => :update, :unless => :status_changed?
    end

    @project = @user.projects.create(:name => "New project", :status => "opened")
    @project.update_attributes :status => "archived", :name => "Updated project"
    assert_equal 0, Activity.count
  end
end
