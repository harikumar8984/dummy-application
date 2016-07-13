class CreatePlayerUsageStatsArchives < ActiveRecord::Migration
  def change
    create_table :player_usage_stats_archives do |t|
      t.integer :duration
      t.string :device_detail_id
      t.integer :user_id
      t.string :course_id
      t.string :content_id
      t.string :usage_date

      t.timestamps null: false
    end
  end
end
