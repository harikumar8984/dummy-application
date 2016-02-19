class RemoveSubscriptionTypeFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :type_of_subscription, :string
  end
end
