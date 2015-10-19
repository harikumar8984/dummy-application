class CreateCourseContents < ActiveRecord::Migration
  def change
    create_table :course_contents do |t|

      t.timestamps null: false
    end
  end
end
