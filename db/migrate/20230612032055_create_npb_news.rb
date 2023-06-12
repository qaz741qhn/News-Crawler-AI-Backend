class CreateNpbNews < ActiveRecord::Migration[7.0]
  def change
    create_table :npb_news do |t|
      t.string :title
      t.text :content
      t.string :source
      t.datetime :date
      t.string :image_url

      t.timestamps
    end
  end
end
