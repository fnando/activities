ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string    :login
  end

  create_table :tasks do |t|
    t.string :name
    t.references :user, :project
  end

  create_table :milestones do |t|
    t.string :name
    t.references :user, :project
  end

  create_table :projects do |t|
    t.string :name, :status
    t.references :user
  end

  create_table :activities do |t|
    t.references :tracker, :polymorphic => true, :null => false
    t.references :trackable, :polymorphic => true, :null => false
    t.string :action, :null => false
    t.text :data, :null => true
    t.timestamps
  end
end
