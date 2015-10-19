class AddChildtToUserChild < ActiveRecord::Migration
  def change
    add_reference :user_children, :child, index: true, foreign_key: true
  end
end
