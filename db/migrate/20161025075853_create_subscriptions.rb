class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|

      t.timestamps null: false
      t.integer :user_id
      t.string :status
      t.string  :subscription_type
    end
  end
end
