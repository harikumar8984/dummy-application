class AddNameToChildren < ActiveRecord::Migration
  def change
    add_column :children, :name, :string
  end
end
