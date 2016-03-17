class AddGiftingScenariosToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gifter_first_name, :string
    add_column :users, :gifter_last_name, :string
    add_column :users, :gifter_email, :string
  end
end
