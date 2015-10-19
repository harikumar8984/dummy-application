class AddStatusToContent < ActiveRecord::Migration
  def change
    add_column :contents, :status, :string
  end
end
