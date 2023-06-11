class AddTranslationToNews < ActiveRecord::Migration[7.0]
  def up
    add_column :news, :translation, :text
  end

  def down
    remove_column :news, :translation
  end
end
