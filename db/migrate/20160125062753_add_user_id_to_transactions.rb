class AddUserIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :user_id, :string
  end
end
