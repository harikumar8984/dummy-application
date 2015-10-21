class AddSeqNoToCourseContents < ActiveRecord::Migration
  def change
    add_column :course_contents, :seq_no, :int
  end
end
