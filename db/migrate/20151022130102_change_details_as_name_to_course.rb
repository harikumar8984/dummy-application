class ChangeDetailsAsNameToCourse < ActiveRecord::Migration
  def change
    rename_column :contents, :details, :name
  end
end
