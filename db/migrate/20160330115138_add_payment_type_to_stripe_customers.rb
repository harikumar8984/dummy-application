class AddPaymentTypeToStripeCustomers < ActiveRecord::Migration
  def change
    add_column :stripe_customers, :payment_type, :string
  end
end
