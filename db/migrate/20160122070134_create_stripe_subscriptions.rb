class CreateStripeSubscriptions < ActiveRecord::Migration
  def change
    create_table :stripe_subscriptions do |t|
      t.string :subscription_id
      t.string :status
      t.string :tax_percent
      t.string :subscription_url
      t.datetime :canceled_at
      t.string :user_id
      t.string :plan_id
      t.string :amount
      t.string :interval
      t.timestamps null: false
    end
  end
end
