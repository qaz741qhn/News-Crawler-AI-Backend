class CreateGeneratedHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :generated_histories do |t|
      t.string :history_type
      t.json :keywords
      t.text :content

      t.timestamps
    end
  end
end
