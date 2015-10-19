class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :module_name
      t.string :string
      t.string :criteria
      t.integer :seq_no

      t.timestamps null: false
    end
  end
end
