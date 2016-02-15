class RemoveCriteriaFromCourse < ActiveRecord::Migration
  def change
    remove_column :courses, :criteria, :string
  end
end
