class AddDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :f_name, :string
    add_column :users, :l_name, :string
    add_column :users, :subscription_end_date, :datetime
    add_column :users, :type_of_subscription, :string
    add_column :users, :status, :string
  end
end
