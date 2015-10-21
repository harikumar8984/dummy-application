class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :course_name
      t.string :criteria
      t.timestamps null: false
    end
  end
end
