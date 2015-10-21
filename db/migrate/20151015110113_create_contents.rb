class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :content_type
      t.string :details
      t.string :status

      t.timestamps null: false
    end
  end
end
