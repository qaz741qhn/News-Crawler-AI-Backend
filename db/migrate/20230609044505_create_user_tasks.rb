class CreateUserTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :user_tasks do |t|
      t.string :title
      t.text :detail
      t.string :status, default: 'Unfinished'
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
