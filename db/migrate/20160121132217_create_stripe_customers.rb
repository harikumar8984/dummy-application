class CreateStripeCustomers < ActiveRecord::Migration
  def change
    create_table :stripe_customers do |t|
      t.string :customer_id
      t.string :currency
      t.string :default_source
      t.string :description
      t.timestamps null: false
    end
  end
end
