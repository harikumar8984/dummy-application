class AddUserToPlayerUsageStats < ActiveRecord::Migration
  def change
    add_reference :player_usage_stats, :user, index: true, foreign_key: true
  end
end
