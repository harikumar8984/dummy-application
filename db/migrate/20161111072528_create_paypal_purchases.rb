class CreatePaypalPurchases < ActiveRecord::Migration
  def change
    create_table :paypal_purchases do |t|
      t.integer :user_id
      t.date    :purchase_date
      t.string  :duration
      t.string :description
      t.string :token
      t.timestamps null: false
    end
  end
end
