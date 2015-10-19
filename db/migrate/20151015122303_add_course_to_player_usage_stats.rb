class AddCourseToPlayerUsageStats < ActiveRecord::Migration
  def change
    add_reference :player_usage_stats, :course, index: true, foreign_key: true
  end
end
