class CreatePaypalTransactions < ActiveRecord::Migration
  def change
    create_table :paypal_transactions do |t|
      t.text :notification_params
      t.string :transaction_id
      t.string :status
      t.date    :purchase_date
      t.integer :paypal_purchase_id
      t.timestamps null: false
    end
  end
end
