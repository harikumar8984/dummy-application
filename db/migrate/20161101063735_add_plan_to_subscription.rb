class AddPlanToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :subscription_plan_id, :integer
  end
end
