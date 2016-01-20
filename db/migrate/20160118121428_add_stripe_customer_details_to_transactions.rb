class AddStripeCustomerDetailsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :customer_id, :string
    add_column :transactions, :account_balance, :integer
    add_column :transactions, :currency, :string
    add_column :transactions, :default_source, :string
    add_column :transactions, :delinquent, :boolean
    add_column :transactions, :description, :string
    add_column :transactions, :card_id, :string
    add_column :transactions, :source_url, :string
    add_column :transactions, :subscription_id, :string
    add_column :transactions, :plan_id, :string
    add_column :transactions, :amount, :integer
    add_column :transactions, :interval, :string
    add_column :transactions, :quantity, :integer
    add_column :transactions, :tax_percent, :string
    add_column :transactions, :subscription_url, :string
  end
end
