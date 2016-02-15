class AddCourseCategoryToCourses < ActiveRecord::Migration
  def change
    add_reference :courses, :course_category, index: true, foreign_key: true
  end
end
