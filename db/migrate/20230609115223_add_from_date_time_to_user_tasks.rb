class AddFromDateTimeToUserTasks < ActiveRecord::Migration[7.0]
  def up
    add_column :user_tasks, :from_date_time, :datetime
  end

  def down
    remove_column :user_tasks, :from_date_time
  end
end
