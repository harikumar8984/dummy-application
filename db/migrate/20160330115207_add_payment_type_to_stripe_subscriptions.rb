class AddPaymentTypeToStripeSubscriptions < ActiveRecord::Migration
  def change
    add_column :stripe_subscriptions, :payment_type, :string
  end
end
