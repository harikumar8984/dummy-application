class AddStripeCustomerDetailsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :customer_id, :string
    add_column :transactions, :amount, :integer
    add_column :transactions, :currency, :string
    add_column :transactions, :transaction_id, :string
    add_column :transactions, :invoice_id, :string
    add_column :transactions, :balance_transaction_id, :string
    add_column :transactions, :description, :string
    add_column :transactions, :failure_code, :string
    add_column :transactions, :failure_message, :string
    add_column :transactions, :paid, :boolean
    add_column :transactions, :transaction_type, :string
    add_column :transactions, :statement_descriptor, :string
  end
end
