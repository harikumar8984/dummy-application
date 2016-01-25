class AddSourceUrlToStripeCustomer < ActiveRecord::Migration
  def change
    add_column :stripe_customers, :source_url, :string
  end
end
