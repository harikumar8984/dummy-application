class CreatePlayerUsageStatsAggregates < ActiveRecord::Migration
  def change
    create_table :player_usage_stats_aggregates do |t|
      t.integer :duration
      t.date :usage_date
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
