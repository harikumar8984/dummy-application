class AddUserToStripeCustomer < ActiveRecord::Migration
  def change
    add_reference :stripe_customers, :user, index: true, foreign_key: true
  end
end
