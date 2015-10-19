class CreateChildren < ActiveRecord::Migration
  def change
    create_table :children do |t|
      t.date :dob

      t.timestamps null: false
    end
  end
end
