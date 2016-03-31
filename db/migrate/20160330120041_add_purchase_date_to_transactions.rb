class AddPurchaseDateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :purchase_date, :datetime
  end
end
