class CreateInAppPurchases < ActiveRecord::Migration
  def change
    create_table :in_app_purchases do |t|
      t.string  :apple_id
      t.integer :user_id
      t.date    :purchase_start_date
      t.string  :duration
      t.string :status
      t.timestamps null: false
    end
  end
end
