class CreateInAppPurchaseTransactions < ActiveRecord::Migration
  def change
    create_table :in_app_purchase_transactions do |t|
      t.integer :in_app_purchase_id
      t.date :transaction_date
      t.string :transaction_id
      t.float :amount
      t.integer :user_id
      t.string  :currency
      t.string  :transaction_status
      t.string  :failure_message
      t.boolean :paid
      t.timestamps null: false
    end
  end
end
