class AddDeviceTypeToDeviceDetails < ActiveRecord::Migration
  def change
    add_column :device_details, :device_type, :string
  end
end
