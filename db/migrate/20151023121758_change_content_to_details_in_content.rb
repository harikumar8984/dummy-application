class ChangeContentToDetailsInContent < ActiveRecord::Migration
  def change
    rename_column :contents, :content, :detail
  end
end
