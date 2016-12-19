class AddSubscrtionDateToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :subscription_start_date, :date
    add_column :subscriptions, :subscription_end_date, :date
  end
end
