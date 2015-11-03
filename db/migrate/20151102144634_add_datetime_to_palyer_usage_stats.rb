class AddDatetimeToPalyerUsageStats < ActiveRecord::Migration
  def change
    add_column :player_usage_stats, :usage_date, :datetime
  end
end
