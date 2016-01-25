class AddStripeCustomerToStripeSubscription < ActiveRecord::Migration
  def change
    add_reference :stripe_subscriptions, :stripe_customer, index: true, foreign_key: true
  end
end
