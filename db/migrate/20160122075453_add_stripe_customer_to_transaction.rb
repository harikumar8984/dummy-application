class AddStripeCustomerToTransaction < ActiveRecord::Migration
  def change
    add_reference :transactions, :stripe_customer, index: true, foreign_key: true
  end
end
