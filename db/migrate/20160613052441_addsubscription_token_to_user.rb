class AddsubscriptionTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :subscription_token, :string
  end
end
