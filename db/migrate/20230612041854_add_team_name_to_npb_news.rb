class AddTeamNameToNpbNews < ActiveRecord::Migration[7.0]
  def up
    add_column :npb_news, :team_name, :string
  end

  def down
    remove_column :npb_news, :team_name
  end
end
