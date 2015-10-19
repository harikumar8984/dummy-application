class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :type
      t.string :details

      t.timestamps null: false
    end
  end
end
