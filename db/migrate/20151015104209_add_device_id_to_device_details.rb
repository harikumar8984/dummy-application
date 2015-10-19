class AddDeviceIdToDeviceDetails < ActiveRecord::Migration
  def change
    add_column :device_details, :device_id, :integer
  end
end
