class ChangeDeviceIdDatatypeInDeviceDetails < ActiveRecord::Migration
  def change
    change_column :device_details, :device_id, :string
  end
end
