class AddStatusToHelp < ActiveRecord::Migration
  def change
    add_column :helps, :status, :string
  end
end
