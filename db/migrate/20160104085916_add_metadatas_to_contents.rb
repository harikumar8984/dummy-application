class AddMetadatasToContents < ActiveRecord::Migration
  def change
    add_column :contents, :title, :string
    add_column :contents, :artist, :string
    add_column :contents, :creator, :string
  end
end
