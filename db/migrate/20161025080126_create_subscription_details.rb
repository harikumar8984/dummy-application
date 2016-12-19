class CreateSubscriptionDetails < ActiveRecord::Migration
  def change
    create_table :subscription_details do |t|
      t.timestamps null: false
      t.integer :user_id
      t.integer :subscription_id
      t.string :subscription_type
    end
  end
end
