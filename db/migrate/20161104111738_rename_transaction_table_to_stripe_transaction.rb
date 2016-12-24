class RenameTransactionTableToStripeTransaction < ActiveRecord::Migration
  def change
    rename_table :transactions, :stripe_transactions
  end
end
