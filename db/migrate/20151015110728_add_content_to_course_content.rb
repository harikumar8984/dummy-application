class AddContentToCourseContent < ActiveRecord::Migration
  def change
    add_reference :course_contents, :content, index: true, foreign_key: true
  end
end
