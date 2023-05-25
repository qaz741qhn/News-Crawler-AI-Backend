class AddDateToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :date, :datetime
  end
end
