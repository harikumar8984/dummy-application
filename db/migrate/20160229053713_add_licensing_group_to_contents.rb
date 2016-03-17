class AddLicensingGroupToContents < ActiveRecord::Migration
  def change
    add_column :contents, :licensing, :string
    add_column :contents, :licensing_group, :string
    add_column :contents, :CAE_IPI, :string
  end
end
