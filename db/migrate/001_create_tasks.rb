class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table "tasks", :force => true do |t|
      t.column :name, :string
      t.column :schedule_method, :string
      t.column :schedule_every, :string
      t.column :shell_command, :string
      t.column :job_id, :string
    end
  end

  def self.down
    drop_table :tasks
  end
end
