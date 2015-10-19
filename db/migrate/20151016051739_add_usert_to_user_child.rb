class AddUsertToUserChild < ActiveRecord::Migration
  def change
    add_reference :user_children, :user, index: true, foreign_key: true
  end
end
