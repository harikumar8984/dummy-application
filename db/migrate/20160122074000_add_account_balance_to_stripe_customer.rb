class AddAccountBalanceToStripeCustomer < ActiveRecord::Migration
  def change
    add_column :stripe_customers, :account_balance, :integer
  end
end
