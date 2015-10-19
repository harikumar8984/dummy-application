class AddCourseToCourseContent < ActiveRecord::Migration
  def change
    add_reference :course_contents, :course, index: true, foreign_key: true
  end
end
