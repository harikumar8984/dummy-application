class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.string :name, null: false , comment: 'the name of the plan'
      t.string :display_name, null: false, comment: 'the display name which to show in webview'
      t.float :amount, null: false, comment: 'the amount of the plan'
      t.string :interval,  comment: 'the interval at which transaction'
      t.timestamps null: false
    end
  end


end
