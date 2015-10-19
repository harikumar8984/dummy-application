class CreatePlayerUsageStats < ActiveRecord::Migration
  def change
    create_table :player_usage_stats do |t|
      t.integer :duration

      t.timestamps null: false
    end
  end
end
