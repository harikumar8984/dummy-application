class AddDeviseToPlayerUsageStats < ActiveRecord::Migration
  def change
    add_reference :player_usage_stats, :device_detail, index: true, foreign_key: true
  end
end
