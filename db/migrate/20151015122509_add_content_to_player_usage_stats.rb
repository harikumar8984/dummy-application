class AddContentToPlayerUsageStats < ActiveRecord::Migration
  def change
    add_reference :player_usage_stats, :content, index: true, foreign_key: true
  end
end
